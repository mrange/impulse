#include "stdafx.h"
#include "resource.h"

#include <windows.h>
#include <commctrl.h>
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

#include "common.hpp"

#pragma comment(lib, "Comctl32")

#pragma comment(linker, "\"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

extern int show__screen (int nCmdShow, bool full_screen_mode, int divider);

namespace
{
  HINSTANCE hinst;
}

HINSTANCE get__hinstance () noexcept
{
  return hinst;
}

extern "C"
{
int APIENTRY wWinMain (
    HINSTANCE hInstance
  , HINSTANCE hPrevInstance
  , LPWSTR    lpCmdLine
  , int       nCmdShow
  )
{
  try
  {
    hinst = hInstance; // Store instance handle in our global variable

    CHECK (SetProcessDPIAware ());

    CHECK_HR (CoInitialize (0));
    auto on_exit__co_unitialize = on_exit_do ([] { CoUninitialize (); });

    InitCommonControls ();

    std::wstring command_line (lpCmdLine);
    std::wregex re_commands (LR"*(^\s*(()|(/window)|(/fullscreen)|(/fullscreen2x))\s*$)*", std::regex_constants::ECMAScript | std::regex_constants::icase);

    auto invalid_command_line_msg = std::string ("Invalid argument, expecting no arguments, /window, /fullscreen or /fullscreen2x\r\n") + utf8_encode (command_line);

    std::wcmatch match;
    if (!std::regex_match (command_line.c_str (), match, re_commands))
    {
      throw std::runtime_error (invalid_command_line_msg.c_str ());
    }

    assert (match.size () == 6);

    if (match[2].matched)
    {
      show__screen (nCmdShow, false, 1);
      return 0;
    }
    else if (match[3].matched)
    {
      show__screen (nCmdShow, false, 1);
      return 0;
    }
    else if (match[4].matched)
    {
      show__screen (nCmdShow, true, 1);
      return 0;
    }
    else if (match[5].matched)
    {
      show__screen (nCmdShow, true, 2);
      return 0;
    }
    else
    {
      throw std::runtime_error (invalid_command_line_msg.c_str ());
    }
  }
  catch (std::exception const & e)
  {
    MessageBoxA (nullptr, e.what (), "Screen Crashed", MB_OK|MB_ICONERROR);
    return 98;
  }
  catch (...)
  {
    MessageBoxW (nullptr, L"Unrecognized exception caught", L"Screen Crashed", MB_OK|MB_ICONERROR);
    return 99;
  }
}
}
