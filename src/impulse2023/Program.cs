
var selections =
  new SelectionPrompt<Screen>()
    .Title("Music: Cuddly - Comic Bakery - Sid (Mad Max)\nPress Esc or Space to exit screen\nWhich screen should I show?")
    .PageSize(10)
    .AddChoices(
        new Impulse2023.GlimGlam.TheScreen    ()
      , new Impulse2023.Jez.TheScreen         ()
      , new Impulse2023.Lance.CubeScreen      ()
      , new Impulse2023.Lance.StarsScreen     ()
      , new Impulse2023.Lance.RasterBarsScreen()
      , new Impulse2023.LongShot.TheScreen    ()
      , new Impulse2023.GuestStar.TheScreen   ()
      , new ExitScreen                        ()
      );

var exePath = Assembly.GetExecutingAssembly().Location;
var path = Path.GetDirectoryName(exePath);
var songPath = Path.Combine(path!, "mad-max--cuddly-comic-bakery-sid.mp3");
var player = new Player();
await player.Play(songPath);

try
{
  var clock = Stopwatch.StartNew();

  while(true)
  {
    var screen = AnsiConsole.Prompt(selections);
    if (screen is ExitScreen)
    {
      break;
    }

    var w     = AnsiConsole.Profile.Width/2;
    var h     = AnsiConsole.Profile.Height;
    var canvas= new Canvas(w, h)
    {
      Scale = false
    };

    AnsiConsole
      .Live(canvas)
      .Start(ldc => Updater(clock, canvas, screen, ldc))
      ;
  }
}
finally
{
  await player.Stop();
}
static void Updater(Stopwatch clock, Canvas canvas, Screen screen, LiveDisplayContext ldc)
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
    var waitFor = 1.0/120.0 - (after-before);
    if (waitFor > 0.0)
    {
      // Strive for 60fps
      var ms = (int)(waitFor*1000.0);
      Thread.Sleep(ms);
    }
  }
}

abstract class Screen
{
  public abstract string Name { get; }
  public abstract void Update(Canvas canvas, double time);

  public override string ToString() => Name;
}

sealed class ExitScreen : Screen
{
  public override string Name => "Exit";

  public override void Update(Canvas canvas, double time)
  {
    throw new NotImplementedException();
  }
}
