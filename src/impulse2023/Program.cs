
Action<Canvas, double> empty = (c, t) => {};
var screen = AnsiConsole.Prompt(
  new SelectionPrompt<Screen>()
    .Title("Which screen should I show?")
    .PageSize(10)
    .AddChoices(
        new Impulse2023.GlimGlam.TheScreen    ()
      , new Impulse2023.Jez.TheScreen         ()
      , new Impulse2023.Lance.CubeScreen      ()
      , new Impulse2023.Lance.RasterBarsScreen()
      , new Impulse2023.LongShot.TheScreen    ()
      , new Impulse2023.GuestStar.TheScreen   ()
      )
  );

var w     = AnsiConsole.Profile.Width/2;
var h     = AnsiConsole.Profile.Height;
var canvas= new Canvas(w, h)
{
  Scale = false
};

var clock = Stopwatch.StartNew();
AnsiConsole.Live(canvas).Start(Updater);

void Updater(LiveDisplayContext ldc)
{
  var cont = true;
  while(cont)
  {
    var before = clock.ElapsedMilliseconds/1000.0;
    var time = before;
    screen.Update(canvas, time);
    ldc.Refresh();
    if (Console.KeyAvailable)
    {
      var key = Console.ReadKey();
      cont = key.Key switch
      {
        ConsoleKey.Spacebar => false
      , ConsoleKey.Escape   => false
      , _                   => true
      };
    }

    var after = clock.ElapsedMilliseconds/1000.0;
    var waitFor = 1.0/60.0 - (after-before);
    if (waitFor > 0.0)
    {
      // Strive for 60fps
      Thread.Sleep((int)(waitFor*1000.0));
    }
  }
}

abstract class Screen
{
  public abstract string Name { get; }
  public abstract void Update(Canvas canvas, double time);

  public override string ToString() => Name;
}

sealed class EmptyScreen : Screen
{
  readonly string _name;

  public EmptyScreen(string name)
  {
    _name = name;
  }
  public override string Name => _name;

  public override void Update(Canvas canvas, double time)
  {
  }
}

