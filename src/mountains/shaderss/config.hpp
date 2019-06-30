#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <wincodec.h>

#include "common.hpp"

struct shader_configuration
{
  std::string   source          ;

  float         start_time      ;
  float         end_time        ;
  float         speed           ;

  std::wstring  image_path      ;
};
shader_configuration get__current_configuration ();

struct loaded_shader_configuration
{
  shader_configuration            shader_configuration    ;

  com_ptr<IWICFormatConverter>    image_converter         ;

  std::pair<UINT, UINT>           get__image_dimensions ();
  std::vector<BYTE>               get__image_bits       ();
};
loaded_shader_configuration load__configuration (shader_configuration const & configuration);
