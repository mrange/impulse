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

#define PERIOD 6.75f
#undef max

namespace
{
  using GLuints = std::vector<GLuint> ;

  bool          done                ;
  bool          full_screen_mode    ;

  HWND          hwnd                ;
  HDC           hdc                 ;

  LONG          width               ;
  LONG          height              ;

  int           divider             ;

  LONG          rbwidth             ;
  LONG          rbheight            ;

  HGLRC         hrc                 ;
  GLuint        pid                 ;
  GLuint        fbo                 ;
  GLuint        rbo                 ;
  GLuint        fsid                ;
  GLuint        vsid                ;

  GLuints       tids                ;

  float         start_time = 0      ;
  float         duration   = 1E22F  ;
  float         speed      = 1      ;

  LARGE_INTEGER counter_freq        ;
  LARGE_INTEGER counter_start       ;

  MCIDEVICEID   music_device        ;

  constexpr int gl_functions_count = 20;

  char const * const gl_names[gl_functions_count] =
  {
    "glCreateShaderProgramv"    ,
    "glGenProgramPipelines"     ,
    "glBindProgramPipeline"     ,
    "glUseProgramStages"        ,
    "glProgramUniform4fv"       ,
    "glGetProgramiv"            ,
    "glGetProgramInfoLog"       ,
    "glProgramUniform1f"        ,
    "glProgramUniform2fv"       ,
    "glActiveTexture"           ,
    "glBindSampler"             ,
    "glProgramUniform1i"        ,
    "glGenerateMipmap"          ,
    "glGenFramebuffers"         ,
    "glBindFramebuffer"         ,
    "glFramebufferRenderbuffer" ,
    "glGenRenderbuffers"        ,
    "glBindRenderbuffer"        ,
    "glRenderbufferStorage"     ,
    "glBlitFramebuffer"         ,
  };

  void * gl_functions[gl_functions_count];

  #define oglCreateShaderProgramv         ((PFNGLCREATESHADERPROGRAMVPROC)    gl_functions[0])
  #define oglGenProgramPipelines          ((PFNGLGENPROGRAMPIPELINESPROC)     gl_functions[1])
  #define oglBindProgramPipeline          ((PFNGLBINDPROGRAMPIPELINEPROC)     gl_functions[2])
  #define oglUseProgramStages             ((PFNGLUSEPROGRAMSTAGESPROC)        gl_functions[3])
  #define oglProgramUniform4fv            ((PFNGLPROGRAMUNIFORM4FVPROC)       gl_functions[4])
  #define oglGetProgramiv                 ((PFNGLGETPROGRAMIVPROC)            gl_functions[5])
  #define oglGetProgramInfoLog            ((PFNGLGETPROGRAMINFOLOGPROC)       gl_functions[6])
  #define oglProgramUniform1f             ((PFNGLPROGRAMUNIFORM1FPROC)        gl_functions[7])
  #define oglProgramUniform2fv            ((PFNGLPROGRAMUNIFORM2FVPROC)       gl_functions[8])
  #define oglActiveTexture                ((PFNGLACTIVETEXTUREPROC)           gl_functions[9])
  #define oglBindSampler                  ((PFNGLBINDSAMPLERPROC)             gl_functions[10])
  #define oglProgramUniform1i             ((PFNGLPROGRAMUNIFORM1IPROC)        gl_functions[11])
  #define oglGenerateMipmap               ((PFNGLGENERATEMIPMAPPROC)          gl_functions[12])
  #define oglGenFramebuffers              ((PFNGLGENFRAMEBUFFERSPROC)         gl_functions[13])
  #define oglBindFramebuffer              ((PFNGLBINDFRAMEBUFFERPROC)         gl_functions[14])
  #define oglFramebufferRenderbuffer      ((PFNGLFRAMEBUFFERRENDERBUFFERPROC) gl_functions[15])
  #define oglGenRenderbuffers             ((PFNGLGENRENDERBUFFERSPROC)        gl_functions[16])
  #define oglBindRenderbuffer             ((PFNGLBINDRENDERBUFFERPROC)        gl_functions[17])
  #define oglRenderbufferStorage          ((PFNGLRENDERBUFFERSTORAGEPROC)     gl_functions[18])
  #define oglBlitFramebuffer              ((PFNGLBLITFRAMEBUFFERPROC)         gl_functions[19])

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
    wcex.hbrBackground  = (HBRUSH) GetStockObject (BLACK_BRUSH);
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
    CHECK (GetClientRect (hwnd, &client));
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

    hdc = CHECK (GetDC (hwnd));

    auto pf = CHECK (ChoosePixelFormat (hdc,&pfd));

    CHECK (SetPixelFormat (hdc,pf,&pfd));

    hrc = CHECK (wglCreateContext (hdc));

    CHECK (wglMakeCurrent (hdc, hrc));

    for (auto i = 0; i < gl_functions_count; ++i)
    {
      gl_functions[i] = CHECK (wglGetProcAddress (gl_names[i]));
    }

    rbwidth   = width/divider;
    rbheight  = height/divider;
    if (divider > 1) {
      // Setting up off-screen render buffer if divider is greater than 1
      oglGenFramebuffers (1, &fbo);
      oglGenRenderbuffers (1, &rbo);
      oglBindRenderbuffer (GL_RENDERBUFFER, rbo);
      oglRenderbufferStorage (GL_RENDERBUFFER, GL_RGBA8, rbwidth, rbheight);
      oglBindFramebuffer (GL_DRAW_FRAMEBUFFER, fbo);
      oglFramebufferRenderbuffer (GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rbo);
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
          oglGenerateMipmap (GL_TEXTURE_2D);
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
    float time = start_time + fmodf (now*speed, duration);

    int period = static_cast<int> (time / PERIOD);
    float timeInPeriod = std::fmodf (time, PERIOD);

    float reso[2]
    {
        rbwidth*1.f
      , rbheight*1.f
    };

    glViewport (0, 0, rbwidth, rbheight);

    if (divider > 1)
    {
      oglBindFramebuffer (GL_DRAW_FRAMEBUFFER, fbo);
    }
    else
    {
      oglBindFramebuffer (GL_DRAW_FRAMEBUFFER, 0);
    }

    oglProgramUniform1f  (fsid, 0 , time);
    oglProgramUniform1i  (fsid, 10, period);
    oglProgramUniform1f  (fsid, 11, timeInPeriod);
    oglProgramUniform2fv (fsid, 1 , 1, reso);

    auto tidx = 0;

    for (auto && tid : tids)
    {
      oglActiveTexture (GL_TEXTURE0 + tidx);
      glBindTexture (GL_TEXTURE_2D, tid);
      oglProgramUniform1i (fsid, 2 + tidx, tidx);
      ++tidx;
    }

    glRects (-1, -1, 1, 1);

    if (divider > 1)
    {
      glViewport (0, 0, width, height);
      oglBindFramebuffer (GL_READ_FRAMEBUFFER, fbo);
      oglBindFramebuffer (GL_DRAW_FRAMEBUFFER, 0);
      oglBlitFramebuffer (0, 0, rbwidth, rbheight, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
    }
  }

  bool file_exists (wchar_t const* file_name)
  {
    WIN32_FIND_DATA ffd {};
    auto handle = FindFirstFileW (L"music.mp3", &ffd);
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
      CHECK_MCI (mciSendStringW (LR"PATH(open "music.mp3" alias music)PATH", nullptr, 0, hwnd));
      music_device = mciGetDeviceIDW (L"music");
      CHECK_MCI (mciSendStringW (L"set music time format milliseconds", nullptr, 0, hwnd));
//      CHECK_MCI (mciSendStringW (L"seek music to 480000", nullptr, 0, hwnd));
      CHECK_MCI (mciSendStringW (L"cue music", nullptr, 0, hwnd));
    }
  }

  void play_music ()
  {
    if (music_device != 0)
    {
      CHECK_MCI (mciSendStringW (L"play music", nullptr, 0, hwnd));
    }
  }

}

double get__now ()
{
  if (music_device != 0)
  {
    MCI_STATUS_PARMS mci_status {};
    mci_status.dwItem = MCI_STATUS_POSITION;
    CHECK_MCI (mciSendCommandW(
        music_device
      , MCI_STATUS
      , MCI_STATUS_ITEM | MCI_WAIT
      , reinterpret_cast<DWORD_PTR> (&mci_status)));

    auto ms = mci_status.dwReturn;

    return ms / 1000.0;
  }
  else
  {
    auto freq_multiplier = 1. / counter_freq.QuadPart;

    LARGE_INTEGER now {};

    QueryPerformanceCounter (&now);

    return freq_multiplier*(now.QuadPart - counter_start.QuadPart);
  }
}

int show__screen (int nCmdShow, bool fsm, int div)
{
  full_screen_mode = fsm;
  divider = std::max (1, div);

  register_class ();

  init_window (nCmdShow);

  init_opengl ();

  init_music ();

  MessageBoxW (
    hwnd
  , L"Impulse psychedelic dreams in 2D\n\nMusic 'Sprung' by 'Astroboy'\nLicensed under CC BY-NC-ND 3.0\nDownloaded from: https://sampleswap.org/"
  , L"Impulse psychedelic dreams in 2D"
  , MB_OK
  );

  play_music ();

  HACCEL hAccelTable = LoadAccelerators (get__hinstance (), MAKEINTRESOURCE (IDC_SHADERSS));

  MSG msg;

  CHECK (QueryPerformanceFrequency (&counter_freq));

  CHECK (QueryPerformanceCounter (&counter_start));

  int       frames          = 0;
  int       total_frames    = 0;
  long long last_second     = 0;
  wchar_t window_title[256] {};

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

    auto time = get__now ();

    if (time > duration)
    {
      done = true;
    }

    draw_gl (static_cast<float> (time));

    SwapBuffers (hdc);

    ++total_frames;
    ++frames;

    auto second = static_cast<long long> (time);

    if (!full_screen_mode && second > last_second)
    {
      last_second = second;
      std::swprintf (window_title, (sizeof window_title)/2, L"FPS: %i, TIME: %0.2f", frames, time);
      SetWindowText (hwnd, window_title);
      frames = 0;
    }
  }

  return 0;
}
