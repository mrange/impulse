using System;
using System.Diagnostics;
using System.IO;
using System.Windows;

namespace Loader
{
  public partial class MainWindow : Window
  {
    readonly string m_rootPath;

    void Open(string cmd, string args = null)
    {
      if (string.IsNullOrWhiteSpace(args))
      {
        Process.Start(cmd);
      }
      else
      {
        Process.Start(cmd, args);
      }
    }

    void Spotify(string id)
    {
      Open($"https://open.spotify.com/track/{id}");
    }

    void Launch(string app, string args = null)
    {
      Open(Path.Combine(m_rootPath, app), args);
    }

    public MainWindow()
    {
      InitializeComponent();
      m_rootPath = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"..\..\.."));
      Spotify("2JQQuLi7Dfs8PliuUAUMp2");
    }


    void RunGravity(object sender, RoutedEventArgs e)
    {
      Launch(@"gravity\bin\Release\gravity.exe");
    }

    static string GetTag(object o)
    {
      var dobj = o as FrameworkElement;
      return dobj?.Tag?.ToString() ?? "";
    }

    void RunImpulseExperience(object sender, RoutedEventArgs e)
    {
      Launch(@"drawinstanced\bin\Release\DrawInstanced.exe", GetTag(sender));
    }

    void RunRaytracer(object sender, RoutedEventArgs e)
    {
      Launch(@"raytracer\bin\Release\RayTracer.exe");
    }

    void RunMandelbrot(object sender, RoutedEventArgs e)
    {
      Launch(@"x64\Release\Mandelbrot.exe");
    }

    void RunMandelbrot2(object sender, RoutedEventArgs e)
    {
      Launch(@"x64\Release\Mandelbrot2.exe");
    }

    void RunTurtle(object sender, RoutedEventArgs e)
    {
      Launch(@"turtle\bin\Release\turtle.exe", GetTag(sender));
    }
  }
}
