#include "stdafx.h"

#include <algorithm>
#include <cstdio>
#include <cwchar>

#include "config.hpp"

shader_configuration get__current_configuration ()
{
  return shader_configuration
  {
      0
    , 340
    , 1
    , { L"value_noise.png", L"impulse.png" }
  };
}

std::pair<UINT, UINT> loaded_image::get__image_dimensions ()
{
  CHECK (image_converter);
  UINT wic_width = 0;
  UINT wic_height = 0;
  CHECK_HR (image_converter->GetSize (&wic_width, &wic_height));
  return std::make_pair (wic_width, wic_height);
}
std::vector<BYTE> loaded_image::get__image_bits ()
{
  CHECK (image_converter);

  auto dim        = get__image_dimensions ();
  auto wic_width  = dim.first;
  auto wic_height = dim.second;

  auto stride = wic_width*3;

  std::vector<BYTE> pixels;
  pixels.resize (stride*wic_height);

  WICRect wic_rect { 0, 0, static_cast<INT> (wic_width), static_cast<INT> (wic_height) };

  CHECK_HR (image_converter->CopyPixels (
      &wic_rect
    , 3*wic_width
    , static_cast<UINT> (pixels.size ())
    , &pixels.front ()
    ));

  std::vector<BYTE> row;
  row.resize (stride);

  /*
  for (auto y = 0U; y < wic_height/2; ++y)
  {
    auto from = y;
    auto to   = wic_height - y - 1;

    auto pb   = pixels.begin ();
    auto rb   = row.begin ();

    std::copy (pb + from*stride , pb + from*stride + stride , rb              );
    std::copy (pb + to*stride   , pb + to*stride + stride   , pb + from*stride);
    std::copy (rb               , rb + stride               , pb + to*stride  );
  }
  */

  return pixels;
}

loaded_shader_configuration load__configuration (shader_configuration const & configuration)
{
  auto fragment_file = std::fopen ("fragment.glsl", "r");
  CHECK (fragment_file != nullptr);
  auto on_exit__close_file = on_exit_do ([fragment_file] { std::fclose (fragment_file); });

  std::string fragment_source;

  char fragment_line[1024] = {};

  while (std::fgets (fragment_line, sizeof fragment_line, fragment_file) != nullptr)
  {
    fragment_source += fragment_line;
  }

  CHECK (std::feof (fragment_file) != 0);

  loaded_images loaded_images;

  for (auto && image_path : configuration.image_paths)
  {
    auto wic = cocreate_instance<IWICImagingFactory> (CLSID_WICImagingFactory);

    com_ptr<IWICBitmapDecoder> wic_decoder;

    CHECK_HR (wic->CreateDecoderFromFilename(
        image_path.c_str ()
      , nullptr
      , GENERIC_READ
      , WICDecodeMetadataCacheOnDemand
      , wic_decoder.out ()
      ));

    com_ptr<IWICBitmapFrameDecode> wic_frame_decoder;
    CHECK_HR (wic_decoder->GetFrame (0, wic_frame_decoder.out ()));

    com_ptr<IWICFormatConverter> wic_format_converter;
    CHECK_HR (wic->CreateFormatConverter (wic_format_converter.out ()));

    CHECK_HR (wic_format_converter->Initialize (
        wic_frame_decoder.get ()
      , GUID_WICPixelFormat24bppRGB
      , WICBitmapDitherTypeNone
      , nullptr
      , 0.F
      , WICBitmapPaletteTypeCustom
      ));

    loaded_images.push_back(loaded_image { image_path, wic_format_converter });
  }

  return
  {
      configuration
    , fragment_source
    , loaded_images
  };
}

