#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <wincodec.h>

#include "common.hpp"

using image_paths = std::vector<std::wstring> ;

struct shader_configuration
{
  float         start_time      ;
  float         period          ;
  float         speed           ;

  image_paths   image_paths     ;
};
shader_configuration get__current_configuration ();

struct loaded_image
{
  std::wstring                    image_path              ;
  com_ptr<IWICFormatConverter>    image_converter         ;

  std::pair<UINT, UINT>           get__image_dimensions ();
  std::vector<BYTE>               get__image_bits       ();
};

using loaded_images = std::vector<loaded_image>;
struct loaded_shader_configuration
{
  shader_configuration            shader_configuration    ;

  std::string                     fragment_source         ;

  loaded_images                   loaded_images           ;
};
loaded_shader_configuration load__configuration (shader_configuration const & configuration);
