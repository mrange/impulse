#include "stdafx.h"
#include "resource.h"

#include <windows.h>
#include <wincodec.h>
#include <GL/gl.h>

#include <algorithm>
#include <cassert>
#include <memory>
#include <regex>
#include <stdexcept>
#include <string>
#include <utility>

#include "glext.h"

#include <Mmsystem.h>
#include <mciapi.h>

#include "common.hpp"
#include "config.hpp"

#pragma comment(lib, "Opengl32")
#pragma comment(lib, "Winmm.lib")

extern HINSTANCE get__hinstance () noexcept;

#define PERIOD 22.f

namespace
{
  using GLuints = std::vector<GLuint> ;

  bool          done                ;
  bool          full_screen_mode    ;

  HWND          hwnd                ;
  HDC           hdc                 ;

  LONG          width               ;
  LONG          height              ;

  HGLRC         hrc                 ;
  GLuint        pid                 ;
  GLuint        fsid                ;
  GLuint        vsid                ;
  
  GLuints       tids                ;

  bool          open_gl_initialized ;

  float         start_time = 0      ;
  float         duration   = 1E22F  ;
  float         speed      = 1      ;

  constexpr int gl_functions_count = 13;

  char const * const gl_names[gl_functions_count] =
  {
    "glCreateShaderProgramv",
    "glGenProgramPipelines" ,
    "glBindProgramPipeline" ,
    "glUseProgramStages"    ,
    "glProgramUniform4fv"   ,
    "glGetProgramiv"        ,
    "glGetProgramInfoLog"   ,   
    "glProgramUniform1f"    ,
    "glProgramUniform2fv"   ,
    "glActiveTexture"       ,
    "glBindSampler"         ,
    "glProgramUniform1i"    ,
    "glGenerateMipmap"      ,
  };

  void * gl_functions[gl_functions_count];

  #define oglCreateShaderProgramv         ((PFNGLCREATESHADERPROGRAMVPROC)  gl_functions[0])
  #define oglGenProgramPipelines          ((PFNGLGENPROGRAMPIPELINESPROC)   gl_functions[1])
  #define oglBindProgramPipeline          ((PFNGLBINDPROGRAMPIPELINEPROC)   gl_functions[2])
  #define oglUseProgramStages             ((PFNGLUSEPROGRAMSTAGESPROC)      gl_functions[3])
  #define oglProgramUniform4fv            ((PFNGLPROGRAMUNIFORM4FVPROC)     gl_functions[4])
  #define oglGetProgramiv                 ((PFNGLGETPROGRAMIVPROC)          gl_functions[5])
  #define oglGetProgramInfoLog            ((PFNGLGETPROGRAMINFOLOGPROC)     gl_functions[6])
  #define oglProgramUniform1f             ((PFNGLPROGRAMUNIFORM1FPROC)      gl_functions[7])
  #define oglProgramUniform2fv            ((PFNGLPROGRAMUNIFORM2FVPROC)     gl_functions[8])
  #define oglActiveTexture                ((PFNGLACTIVETEXTUREPROC)         gl_functions[9])
  #define oglBindSampler                  ((PFNGLBINDSAMPLERPROC)           gl_functions[10])
  #define oglProgramUniform1i             ((PFNGLPROGRAMUNIFORM1IPROC)      gl_functions[11])
  #define oglGenerateMipmap               ((PFNGLGENERATEMIPMAPPROC)        gl_functions[12])

  PIXELFORMATDESCRIPTOR const pfd =
  {
    sizeof(PIXELFORMATDESCRIPTOR)                         ,
    1                                                     ,
    PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER,
    PFD_TYPE_RGBA                                         ,
    24                                                    ,
    0, 0, 0, 0, 0, 0, 8, 0                                ,
    0, 0, 0, 0, 0                                         , // accum
    32                                                    , // zbuffer
    0                                                     , // stencil
    0                                                     , // aux
    PFD_MAIN_PLANE                                        ,
    0, 0, 0, 0                                            ,
  };

  WCHAR const window_title[]      = L"Impulse 2D Psychedelics"; // The title bar text
  WCHAR const window_class_name[] = L"SHADER_SS"          ; // the main window class name

  char const vertex_shader[] = R"SHADER(
#version 460

#define SCREEN_LOADER

layout (location=0) in vec2 inVer;
out vec2 p;
out vec2 q;

out gl_PerVertex
{
  vec4 gl_Position;
};

void main()
{
  gl_Position=vec4(inVer,0.0,1.0);
  p=inVer;
  q=0.5*inVer+0.5;
}
)SHADER";

  int check_link_status (int id, char const * msg)
  {
    int result;
    oglGetProgramiv (id, GL_LINK_STATUS, &result);
    if (!result)
    {
      char    info[1536] {};

      oglGetProgramInfoLog (id, 1024, nullptr, info);
      OutputDebugStringA (msg);
      OutputDebugStringW (L"\n");
      OutputDebugStringA (info);
      OutputDebugStringW (L"\n");
      throw std::runtime_error (msg);
    }

    return id;
  }

  #define CHECK_LINK_STATUS(expr) check_link_status (expr, (__FILE__ "(" STRINGIFY(__LINE__) "): Check link status failed for - " #expr))

  MCIERROR check_mci (MCIERROR err, char const * msg)
  {
    if (err != 0)
    {
      wchar_t   info[1536] {};

      OutputDebugStringA (msg);
      OutputDebugStringW (L"\n");
      if (mciGetErrorString (err, info, sizeof info / 2))
      {
        OutputDebugStringW (info);
        OutputDebugStringW (L"\n");
      }
      throw std::runtime_error (msg);
    }

    return err;
  }


  #define CHECK_MCI(expr) check_mci (expr, (__FILE__ "(" STRINGIFY(__LINE__) "): MCI call failed for - " #expr))

  LRESULT CALLBACK window_proc (HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
  {
    auto kill = [] ()
    {
      done = true;
      PostQuitMessage (0);
    };

    switch (message)
    {
      case WM_SIZE:
      width  = LOWORD (lParam);
      height = HIWORD (lParam);
      if (open_gl_initialized)
      {
        glViewport (0, 0, width, height);
      }
      return 0;
    case WM_PAINT:
      {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint (hWnd, &ps);
        // TODO: Add any drawing code that uses hdc here...
        EndPaint (hWnd, &ps);
      }
      return 0;
    case WM_DESTROY:
      kill ();
      return 0;
    default:
      return DefWindowProc (hWnd, message, wParam, lParam);
    }
  }

  ATOM register_class ()
  {
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof (WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = window_proc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = get__hinstance ();
    wcex.hIcon          = LoadIcon (get__hinstance (), MAKEINTRESOURCE (IDI_SHADERSS));
    wcex.hCursor        = LoadCursor (nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH) GetStockObject(BLACK_BRUSH);
    wcex.lpszMenuName   = nullptr;
    wcex.lpszClassName  = window_class_name;
    wcex.hIconSm        = LoadIcon (wcex.hInstance, MAKEINTRESOURCE (IDI_SHADERSS));

    return CHECK (RegisterClassExW (&wcex));
  }

  void init_window (int nCmdShow)
  {
    hwnd = CHECK (CreateWindowExW (
        0
      , window_class_name
      , window_title
      , WS_VISIBLE | WS_OVERLAPPEDWINDOW
      , CW_USEDEFAULT
      , CW_USEDEFAULT
      , 1920 + 22
      , 1080 + 56
      , nullptr
      , nullptr
      , get__hinstance ()
      , nullptr
      ));

    if (full_screen_mode)
    {
      auto cx = GetSystemMetrics (SM_CXSCREEN);
      auto cy = GetSystemMetrics (SM_CYSCREEN);

      auto style = GetWindowLongW (hwnd, GWL_STYLE);
      style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
      SetWindowLongW (hwnd, GWL_STYLE, style);

      auto ex_style = GetWindowLongW (hwnd, GWL_EXSTYLE);
      ex_style &= ~(WS_EX_DLGMODALFRAME | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);
      SetWindowLongW (hwnd, GWL_EXSTYLE, ex_style);
      SetWindowPos (
          hwnd
        , nullptr
        , 0
        , 0
        , cx
        , cy
        , SWP_FRAMECHANGED | SWP_NOZORDER | SWP_NOOWNERZORDER
        );
    }

    RECT client;
    CHECK (GetClientRect(hwnd, &client));
    width  = client.right - client.left;
    height = client.bottom - client.top;

    ShowWindow (hwnd, nCmdShow);
    CHECK (UpdateWindow (hwnd));

  }


  using PFN_wglSwapIntervalEXT = BOOL WINAPI (int interval);

  void init_opengl ()
  {
    auto loaded_config  = load__configuration (get__current_configuration ());

    start_time  = loaded_config.shader_configuration.start_time ;
    duration    = loaded_config.shader_configuration.duration   ;
    speed       = loaded_config.shader_configuration.speed      ;

    hdc = CHECK (GetDC(hwnd));

    auto pf = CHECK (ChoosePixelFormat (hdc,&pfd));

    CHECK (SetPixelFormat (hdc,pf,&pfd));

    hrc = CHECK (wglCreateContext (hdc));

    CHECK (wglMakeCurrent(hdc, hrc));

    for (auto i = 0; i < gl_functions_count; ++i)
    {
      gl_functions[i] = CHECK (wglGetProcAddress(gl_names[i]));
    }

    auto tsz = loaded_config.loaded_images.size ();
    if (tsz > 0)
    {
      tids.resize (tsz);
      glGenTextures (static_cast<GLsizei> (tsz), &tids.front ());
      auto tidx = 0;
      for (auto && loaded_image : loaded_config.loaded_images)
      {
        auto dim    = loaded_image.get__image_dimensions ();
        auto pixels = loaded_image.get__image_bits ();
        glBindTexture   (GL_TEXTURE_2D, tids[tidx]);
        glTexImage2D    (GL_TEXTURE_2D, 0, GL_RGB, dim.first, dim.second, 0, GL_RGB, GL_UNSIGNED_BYTE, &pixels.front ());
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        auto single_bit_number = (dim.first & (dim.first - 1)) == 0;
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        if (dim.first == dim.second && single_bit_number)
        {
          oglGenerateMipmap(GL_TEXTURE_2D);
        }
        ++tidx;
      }
    }

    std::string fragment_shader_source = "#version 460\n#define SCREEN_LOADER\n";
    fragment_shader_source += loaded_config.fragment_source;

    auto vsh = vertex_shader;
    auto fsh = fragment_shader_source.c_str ();

    vsid = oglCreateShaderProgramv (GL_VERTEX_SHADER, 1, &vsh);
    fsid = oglCreateShaderProgramv (GL_FRAGMENT_SHADER, 1, &fsh);

    oglGenProgramPipelines (1, &pid);
    oglBindProgramPipeline (pid);
    oglUseProgramStages (pid, GL_VERTEX_SHADER_BIT, vsid);
    oglUseProgramStages (pid, GL_FRAGMENT_SHADER_BIT, fsid);

    if (tsz > 0)
    {
      for (auto && tid : tids)
      {
        CHECK_LINK_STATUS (tid);
      }
    }
    CHECK_LINK_STATUS (vsid);
    CHECK_LINK_STATUS (fsid);
    CHECK_LINK_STATUS (pid);
  }

  void draw_gl (float now)
  {
    float time = start_time + fmodf(now*speed, duration);

    int period = static_cast<int>(time / PERIOD);
    float timeInPeriod = std::fmodf(time, PERIOD);

    float reso[2]
    {
        width*1.f 
      , height*1.f
    };
    
    oglProgramUniform1f  (fsid, 0 , time);
    oglProgramUniform1i  (fsid, 10, period);
    oglProgramUniform1f  (fsid, 11, timeInPeriod);
    oglProgramUniform2fv (fsid, 1 , 1, reso);

    auto tidx = 0;

    for (auto && tid : tids)
    {
      oglActiveTexture(GL_TEXTURE0 + tidx);
      glBindTexture(GL_TEXTURE_2D, tid);
      oglProgramUniform1i(fsid, 2 + tidx, tidx);
      ++tidx;
    }

    glRects (-1, -1, 1, 1);

    open_gl_initialized = true;
  }

  bool file_exists (wchar_t const* file_name)
  {
    WIN32_FIND_DATA ffd {};
    auto handle = FindFirstFileW(L"music.mp3", &ffd);
    if (handle != INVALID_HANDLE_VALUE)
    {
      FindClose (handle);
      return true;
    }
    else
    {
      return false;
    }

  }

  void init_music ()
  {
    if (file_exists (L"music.mp3"))
    {
      CHECK_MCI (mciSendStringW(LR"PATH(open "music.mp3" alias music)PATH", nullptr, 0, hwnd));
      CHECK_MCI (mciSendStringW(L"play music", nullptr, 0, hwnd));
    }
  }

}

int show__screen (int nCmdShow, bool fsm)
{
  full_screen_mode = fsm;

  register_class ();

  init_window (nCmdShow);

  init_opengl ();

  init_music ();

  HACCEL hAccelTable = LoadAccelerators (get__hinstance (), MAKEINTRESOURCE (IDC_SHADERSS));

  MSG msg;

  LARGE_INTEGER freq {};
  LARGE_INTEGER start {};

  CHECK (QueryPerformanceFrequency(&freq));

  CHECK (QueryPerformanceCounter (&start));

  auto      freq_multiplier = 1. / freq.QuadPart;
  int       frames          = 0;
  long long last_second     = 0;
  wchar_t window_title[64]  {};

  // Main message loop:
  while (true)
  {
    while (!done && PeekMessage (&msg, 0, 0, 0, PM_REMOVE))
    {
      if (!TranslateAccelerator (msg.hwnd, hAccelTable, &msg))
      {
        TranslateMessage (&msg);
        DispatchMessage (&msg);
      }
    }

    if (done) break;

    LARGE_INTEGER now {};

    QueryPerformanceCounter (&now);

    auto time = freq_multiplier*(now.QuadPart - start.QuadPart);

    if (time > duration)
    {
      done = true;
    }

    draw_gl (static_cast<float> (time));

    SwapBuffers (hdc);

    ++frames;

    auto second = static_cast<long long >(time);

    if (!full_screen_mode && second > last_second)
    {
      last_second = second;
      std::swprintf (window_title, (sizeof window_title)/2, L"FPS: %i", frames);
      SetWindowText (hwnd, window_title);
      frames = 0;
    }
  }

  return 0;
}
