precision mediump float;

#if defined(SCREEN_LOADER)
in vec2 p;
in vec2 q;
#else
in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;
#endif

layout (location=0) out vec4 fragColor;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

layout (location=0) uniform float time;
layout (location=1) uniform vec2 resolution;

layout (location=10) uniform int period;
layout (location=11) uniform float timeInPeriod;

vec3 mainImage(in vec2, in vec2);
void main(void)
{
#if defined(SCREEN_LOADER)
  fragColor = vec4(mainImage(p, q), 1.0);
#else
  fragColor = vec4(mainImage(-1.0 + 2.0*inData.v_texcoord, inData.v_texcoord), 1.0);
#endif
}

// License CC0: mrange

// ------------------------------==> COMMON <==--------------------------------

struct Effect {
  int      major  ;
  int      minor  ;
  float    seq    ;
  bool     fade   ;
  float    input0 ;
  float    input1 ;
};

#define PI         3.141592654
#define TAU        (2.0*PI)

#define RESOLUTION resolution
#define TIME       time

#define DURATION1  6.85
#define DURATION   5.13
#define DURATIONT  172.0

#define FADEIN     1.0
#define FADEOUT    2.0

#define LESS(a,b,c) mix(a,b,step(0.,c))

#define SABS(x,k)   LESS((.5/k)*x*x+k*.5,abs(x),abs(x)-k)

#define SCA(a)      vec2(sin(a), cos(a))

// Uncomment to speed up experimentation
//#define EXPERIMENTING

#define MINOR_NONE          0

#define MAJOR_NOEFFECT      0

#define MAJOR_IMPULSE       1
#define MINOR_INTRO         0
#define MINOR_OUTRO         1

#define MAJOR_ORRERY        2
#define MINOR_SUNRISE       0
#define MINOR_CLOSEUP       1
#define MINOR_APPROACH      2
#define MINOR_ESCAPE        3

#define MAJOR_WATERWORLD    3

#define MAJOR_BARRENMOON    4

#define MAJOR_GALAXY        5

#define MAJOR_SPACESHIP     6
#define MINOR_FROM_BEHIND   0
#define MINOR_CYLINDER_SEA  1
#define MINOR_FROM_FRONT    2

//#define EXPERIMENTING

#ifdef EXPERIMENTING
#define ENABLE_GALAXY

const Effect effects[] = Effect[](
    Effect(MAJOR_IMPULSE     , MINOR_INTRO          , 0.0, false , 0.0       , 0.0) // This is special in that it's 7 seconds long, all other about ~5.1 long
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 0.0, true  , 0.4       , 0.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 1.0, true  , 0.4       , 0.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 0.0, true  , 2.0       , 2.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 1.0, true  , 2.0       , 2.5)
  );

#else
#define ENABLE_NOEFFECT
#define ENABLE_IMPULSE
#define ENABLE_ORRERY
#define ENABLE_BARRENMOON
#define ENABLE_WATERWORLD
#define ENABLE_GALAXY
#define ENABLE_SPACESHIP

const Effect effects[] = Effect[](
    Effect(MAJOR_IMPULSE     , MINOR_NONE           , 0.0, false , 0.0       , 0.0) // This is special in that it's 7 seconds long, all other about ~5.1 long
  , Effect(MAJOR_ORRERY      , MINOR_SUNRISE        , 0.0, true  , PI/6.0    , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_SUNRISE        , 1.0, true  , PI/6.0    , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_CLOSEUP        , 0.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_CLOSEUP        , 1.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_BEHIND    , 0.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_BEHIND    , 1.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_BEHIND    , 2.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_CYLINDER_SEA   , 0.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_CYLINDER_SEA   , 1.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_CYLINDER_SEA   , 2.0, true  , 0.0       , 200000.0)
  , Effect(MAJOR_ORRERY      , MINOR_APPROACH       , 0.0, true  , -1.1      , 1.0)
  , Effect(MAJOR_ORRERY      , MINOR_APPROACH       , 1.0, true  , -1.1      , 1.0)
  , Effect(MAJOR_BARRENMOON  , MINOR_NONE           , 0.0, true  , 7.0       , 0.0)
  , Effect(MAJOR_BARRENMOON  , MINOR_NONE           , 1.0, true  , 7.0       , 0.0)
  , Effect(MAJOR_BARRENMOON  , MINOR_NONE           , 2.0, true  , 7.0       , 0.0)
  , Effect(MAJOR_BARRENMOON  , MINOR_NONE           , 3.0, true  , 7.0       , 0.0)
  , Effect(MAJOR_WATERWORLD  , MINOR_NONE           , 0.0, true  , 0.0       , 0.0) // 20
  , Effect(MAJOR_WATERWORLD  , MINOR_NONE           , 1.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_WATERWORLD  , MINOR_NONE           , 2.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_WATERWORLD  , MINOR_NONE           , 3.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_ESCAPE         , 0.0, true  , PI/6.0    , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_ESCAPE         , 1.0, true  , PI/6.0    , 0.0)
  , Effect(MAJOR_ORRERY      , MINOR_ESCAPE         , 2.0, true  , PI/6.0    , 0.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_FRONT     , 0.0, true  , PI+0.5    , 550000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_FRONT     , 1.0, true  , PI+0.5    , 550000.0)
  , Effect(MAJOR_SPACESHIP   , MINOR_FROM_FRONT     , 2.0, true  , PI+0.5    , 550000.0)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 0.0, true  , 0.4       , 0.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 1.0, true  , 0.4       , 0.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 0.0, true  , 2.0       , 2.5)
  , Effect(MAJOR_GALAXY      , MINOR_NONE           , 1.0, true  , 2.0       , 2.5)
  , Effect(MAJOR_IMPULSE     , MINOR_OUTRO          , 0.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_IMPULSE     , MINOR_OUTRO          , 1.0, true  , 0.0       , 0.0)
  , Effect(MAJOR_IMPULSE     , MINOR_OUTRO          , 2.0, true  , 0.0       , 0.0)
  );
#endif

// From planet surface
const vec3  skyCol1       = vec3(0.35, 0.45, 0.6);
const vec3  skyCol2       = skyCol1*skyCol1*skyCol1*3.0;
const vec3  skyCol3       = pow(skyCol1, vec3(0.25));
const vec3  sunCol1       = vec3(1.0,0.9,0.8);
const vec3  sunCol2       = vec3(1.0,0.9,0.8);
const vec3  smallSunCol1  = vec3(1.0,0.5,0.25)*0.5;
const vec3  smallSunCol2  = vec3(1.0,0.5,0.25)*0.5;
const vec3  ringColor     = sqrt(vec3(0.95, 0.65, 0.45));
const vec4  planet        = vec4(80.0, -20.0, 100.0, 50.0)*1000.0;
const vec3  planetCol     = sqrt(vec3(0.9, 0.8, 0.7));
const vec3  ringsNormal   = normalize(vec3(1.0, 1.25, 0.0));
const vec4  rings         = vec4(ringsNormal, -dot(ringsNormal, planet.xyz));
const vec3  mountainColor = sqrt(vec3(0.95, 0.65, 0.45));

// From space
const vec3  sunDirection         = normalize(vec3(0.0, 0.5, -10.0));
const vec3  sunColor1            = vec3(1.0, 0.8, 0.8);
const vec3  sunColor2            = vec3(1.0, 0.8, 0.9);
const vec3  smallSunDirection    = normalize(vec3(-2.0, -3.5, -10.0));
const vec3  smallSunColor1       = vec3(1.0, 0.6, 0.6);
const vec3  smallSunColor2       = vec3(1.0, 0.3, 0.6);


vec2 toRect(vec2 p) {
  return p.x*vec2(cos(p.y), sin(p.y));
}

vec2 toPolar(vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}

float saturate(float a) { return clamp(a, 0.0, 1.0); }

float mod1(inout float p, float size) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p + halfsize, size) - halfsize;
  return c;
}

vec2 mod2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size*0.5)/size);
  p = mod(p + size*0.5,size) - size*0.5;
  return c;
}

vec2 mod2_1(inout vec2 p) {
  vec2 c = floor(p + 0.5);
  p = fract(p + 0.5) - 0.5;
  return c;
}

float modPolar(inout vec2 p, float repetitions) {
  float angle = 2.0*PI/repetitions;
  float a = atan(p.y, p.x) + angle/2.;
  float r = length(p);
  float c = floor(a/angle);
  a = mod(a,angle) - angle/2.;
  p = vec2(cos(a), sin(a))*r;
  // For an odd number of repetitions, fix cell index of the cell in -x direction
  // (cell index would be e.g. -5 and 5 in the two halves of the cell):
  if (abs(c) >= (repetitions/2.0)) c = abs(c);
  return c;
}

vec3 hsv2rgb(vec3 c) {
  const vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float parabola(vec2 pos, float k) {
  pos.x = abs(pos.x);

  float p = (1.0-2.0*k*pos.y)/(6.0*k*k);
  float q = -abs(pos.x)/(4.0*k*k);

  float h = q*q + p*p*p;
  float r = sqrt(abs(h));

  float x = (h>0.0) ? pow(-q+r,1.0/3.0) - pow(abs(-q-r),1.0/3.0)*sign(q+r) : 2.0*cos(atan(r,-q)/3.0)*sqrt(-p);

  return length(pos-vec2(x,k*x*x)) * sign(pos.x-x);
}

float sphere(vec3 p, float r) {
  return length(p) - r;
}

float circle(vec2 p, float r) {
  return length(p) - r;
}

float box(vec2 p, vec2 b) {
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float horseshoe(vec2 p, vec2 c, float r, vec2 w) {
  p.x = abs(p.x);
  float l = length(p);
  p = mat2(-c.x, c.y, c.y, c.x)*p;
  p = vec2((p.y>0.0)?p.x:l*sign(-c.x),(p.x>0.0)?p.y:l);
  p = vec2(p.x,abs(p.y-r))-w;
  return length(max(p,0.0)) + min(0.0,max(p.x,p.y));
}

// Not an exact distance field
float softBox(vec3 p, float r) {
  p *= p;
  p *= p;
  p *= p;
  return pow(p.x + p.y + p.z, 1.0/8.0) - r;
}

float torus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float capsule(vec3 p, float h, float r) {
  p.z -= clamp(p.z, 0.0, h);
  return length(p) - r;
}

float cylinder(vec3 p, vec3 c) {
  return length(p.xy-c.xy)-c.z;
}


float l2(vec2 p) {
  return dot(p, p);
}

float l2(vec3 p) {
  return dot(p, p);
}
float spow(float v, float p) {
  return sign(v)*pow(abs(v), p);
}

void rot(inout vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  p = vec2(c*p.x + s*p.y, -s*p.x + c*p.y);
}

float smoother(float f, float r) {
  return tanh(f/r)*r;
}

float egg(vec2 p, float ra, float rb) {
  const float k = sqrt(3.0);
  p.x = abs(p.x);
  float r = ra - rb;
  return ((p.y<0.0)       ? length(vec2(p.x,  p.y    )) - r :
          (k*(p.x+r)<p.y) ? length(vec2(p.x,  p.y-k*r)) :
                              length(vec2(p.x+r,p.y    )) - 2.0*r) - rb;
}

vec2 cylinderCoord(vec3 p) {
  return vec2(p.z, atan(p.x, -p.y));
}

float hash(in vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,58.233))) * 13758.5453);
}

vec2 hash2(vec2 p) {
  p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
  return fract(sin(p)*18.5453);
}

float pmin(float a, float b, float k) {
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

float roundIntersection(float a, float b, float r) {
  vec2 u = max(vec2(r + a,r + b), vec2(0));
  return min(-r, max (a, b)) + length(u);
}

float chamfer(float a, float b, float r) {
  return min(min(a, b), (a - r + b)*sqrt(0.5));
}

float roundDiff (float a, float b, float r) {  return roundIntersection(a, -b, r);
}
float pcos(float f) {
  return 0.5 + 0.5*cos(f);
}

float psin(float f) {
  return 0.5 + 0.5*sin(f);
}

vec2 rayCylinder(vec3 ro, vec3 rd, vec3 cb, vec4 cyl) {
  vec3  oc = ro - cb;
  float card = dot(cyl.xyz ,rd);
  float caoc = dot(cyl.xyz, oc);
  float a = 1.0 - card*card;
  float b = dot(oc, rd) - caoc*card;
  float c = dot(oc, oc) - caoc*caoc - cyl.w*cyl.w;
  float h = b*b - a*c;
  if (h<0.0) return vec2(-1.0); //no intersection
  h = sqrt(h);
  return vec2(-b-h,-b+h)/a;
}

float rayPlane(vec3 ro, vec3 rd, vec4 p) {
  return -(dot(ro,p.xyz)+p.w)/dot(rd,p.xyz);
}

vec2 raySphere(vec3 ro, vec3 rd, vec4 sph) {
  vec3 oc = ro - sph.xyz;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - sph.w*sph.w;
  float h = b*b - c;

  if (h<0.0) return vec2(-1.0);
  h = sqrt(h);
  float t1 = -b - h;
  float t2 = -b + h;

  return mix(vec2(-1.0), vec2(t1, t2),step(0.0, t2));
}


vec3 raySphereDensity(vec3 ro, vec3 rd, vec4 sph, float dbuffer) {
  float ndbuffer = dbuffer/sph.w;
  vec3  rc = (ro - sph.xyz)/sph.w;

  float b = dot(rd,rc);
  float c = dot(rc,rc) - 1.0;
  float h = b*b - c;
  if (h<0.0) return vec3(-1.0, -1.0, 0.0);
  h = sqrt(h);
  float t1 = -b - h;
  float t2 = -b + h;

  if (t2<0.0 || t1>ndbuffer) return vec3(-1.0, -1.0, 0.0);
  t1 = max(t1, 0.0);
  t2 = min(t2, ndbuffer);

  float i1 = -(c*t1 + b*t1*t1 + t1*t1*t1/3.0);
  float i2 = -(c*t2 + b*t2*t2 + t2*t2*t2/3.0);
  return vec3(sph.w*t1, sph.w*t2, (i2-i1)*(3.0/4.0));
}


float vnoise(vec2 x) {
  vec2 i = floor(x);
  vec2 w = fract(x);

#if 1
  // quintic interpolation
  vec2 u = w*w*w*(w*(w*6.0-15.0)+10.0);
#else
  // cubic interpolation
  vec2 u = w*w*(3.0-2.0*w);
#endif

  float a = hash(i+vec2(0.0,0.0));
  float b = hash(i+vec2(1.0,0.0));
  float c = hash(i+vec2(0.0,1.0));
  float d = hash(i+vec2(1.0,1.0));

  float k0 =   a;
  float k1 =   b - a;
  float k2 =   c - a;
  float k3 =   d - c + a - b;

  float aa = mix(a, b, u.x);
  float bb = mix(c, d, u.x);
  float cc = mix(aa, bb, u.y);

  return k0 + k1*u.x + k2*u.y + k3*u.x*u.y;
}

vec4 voronoi(vec2 x) {
  vec2 n = floor(x);
  vec2 f = fract(x);

  vec4 m = vec4(8.0);
  for(int j=-1; j<=1; j++)
  for(int i=-1; i<=1; i++)
  {
    vec2  g = vec2(float(i), float(j));
    vec2  o = hash2(n + g);
    vec2  r = g - f + o;
    float d = dot(r, r);
    if(d<m.x)
    {
      m = vec4(d, o.x + o.y, r);
    }
  }

  return vec4(sqrt(m.x), m.yzw);
}

const vec2 sca0 = SCA(0.0);

float letteri(vec2 p) {
  p.y -= 0.25;
  return box(p, vec2(0.125, 0.75));
}

float letterm(vec2 p) {
  p.y = -p.y;
  float l = horseshoe(p - vec2(+0.5, 0.0), sca0, 0.5, vec2(0.5, 0.1));
  float r = horseshoe(p - vec2(-0.5, 0.0), sca0, 0.5, vec2(0.5, 0.1));
  return min(l, r);
}

float letterp(vec2 p) {
  float b = box(p - vec2(-0.45, -0.25), vec2(0.1, 0.75));
  float c = max(circle(p, 0.5), -circle(p, 0.3));
  return min(b, c);
}

float letteru(vec2 p) {
  return horseshoe(p - vec2(0.0, 0.125), sca0, 0.5, vec2(0.375, 0.1));
}

float letterl(vec2 p) {
  return box(p, vec2(0.125, 0.5));
}

float letters(vec2 p) {
  rot(p, -PI/6.0);
  rot(p, -PI/2.0);
  float u = horseshoe(p - vec2(-0.25*3.0/4.0, -0.125/2.0), sca0, 0.375, vec2(0.2, 0.1)) - 0.0;
  rot(p, PI);
  float l = horseshoe(p - vec2(-0.25*3.0/4.0, -0.125/2.0), sca0, 0.375, vec2(0.2, 0.1));
  return min(u,l);
}

float lettere(vec2 p) {
  return min(box(p, vec2(0.4, 0.1)), max(circle(p, 0.5), -circle(p, 0.3)));
}

float impulse(vec2 p) {
  p.x += 0.6;
  const float oi = -3.00;
  const float om = -1.65;
  const float op = +0.10;
  const float ou = +1.25;
  const float ol = +2.10;
  const float os = +2.80;
  const float oe = +3.85;
  float di = letteri(p - vec2(oi, 0.0));
  float dm = letterm(p - vec2(om, 0.0));
  float dp = letterp(p - vec2(op, 0.0));
  float du = letteru(p - vec2(ou, 0.0));
  float dl = letterl(p - vec2(ol, 0.0));
  float ds = letters(p - vec2(os, 0.0));
  float de = lettere(p - vec2(oe, 0.0));
  float oo = 0.1;
  float dx = abs(p.y) - oo;
  dx = abs(dx) - oo*0.5;
  float d = 1000000.0;
  d = min(d, di);
  d = min(d, dm);
  d = min(d, dp);
  d = min(d, du);
  d = min(d, dl);
  d = min(d, ds);
  d = min(d, de);
  d = max(d, -dx);

  return d;
}

float star(vec2 p, float r, float rf) {
  const vec2 k1 = vec2(0.809016994375, -0.587785252292);
  const vec2 k2 = vec2(-k1.x,k1.y);
  p.x = abs(p.x);
  p -= 2.0*max(dot(k1,p),0.0)*k1;
  p -= 2.0*max(dot(k2,p),0.0)*k2;
  p.x = abs(p.x);
  p.y -= r;
  vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
  float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
  return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

vec3 gasGiant(vec3 ro, vec3 rd, vec3 sunDir) {
  vec2 si = raySphere(ro, rd, planet);
  float pi = rayPlane(ro, rd, rings);

  vec3 planetSurface = ro + si.x*rd;
  vec3 planetNormal = normalize(planetSurface - planet.xyz);
  float planetDiff = max(dot(planetNormal, sunDir), 0.0);
  float planetBorder = max(dot(planetNormal, -rd), 0.0);
  float planetLat = (planetSurface.x+planetSurface.y)*0.0005;
  vec3 planetCol = mix(1.3*planetCol, 0.3*planetCol, pow(psin(planetLat+1.0)*psin(sqrt(2.0)*planetLat+2.0)*psin(sqrt(3.5)*planetLat+3.0), 0.5));

  vec3 ringsSurface = ro + pi*rd;

  float borderTransparency = smoothstep(0.0, 0.1, planetBorder);

  float ringsDist = length(ringsSurface - planet.xyz)*1.0;
  float ringsPeriod = ringsDist*0.001;
  const float ringsMax = 150000.0*0.655;
  const float ringsMin = 100000.0*0.666;
  float ringsMul = pow(psin(ringsPeriod+1.0)*psin(sqrt(0.5)*ringsPeriod+2.0)*psin(sqrt(0.45)*ringsPeriod+4.0)*psin(sqrt(0.35)*ringsPeriod+5.0), 0.25);
  float ringsMix = psin(ringsPeriod*10.0)*psin(ringsPeriod*10.0*sqrt(2.0))*(1.0 - smoothstep(50000.0, 200000.0, pi));

  vec3 ringsCol = mix(vec3(0.125), 0.75*ringColor, ringsMix)*step(-pi, 0.0)*step(ringsDist, ringsMax)*step(-ringsDist, -ringsMin)*ringsMul;

  vec3 final = vec3(0.0);

  final += ringsCol*(step(pi, si.x) + step(si.x, 0.0));

  final += step(0.0, si.x)*pow(planetDiff, 0.75)*mix(planetCol, ringsCol, 0.0)*borderTransparency + ringsCol*(1.0 - borderTransparency);

  return final;
}

vec3 postProcess(vec3 col, vec2 q) {
  //col = saturate(col);
  col=pow(clamp(col,0.0,1.0),vec3(0.75));
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4);  // satuation
//  col*=0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
  return col;
}

// ------------------------------==> COMMON <==--------------------------------

// -----------------------------==> NOEFFECT <==-------------------------------

#ifdef ENABLE_NOEFFECT

vec3 noeffect_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  return vec3(0.0, 0.5, 0.0);
}

#endif

// -----------------------------==> NOEFFECT <==-------------------------------

// -----------------------------==> IMPULSE <==--------------------------------

#ifdef ENABLE_IMPULSE

float impulse_planet(vec2 p) {
  p.y = abs(p.y);
  float dc1 = circle(p, 2.0);
  float dc2 = circle(p+vec2(0.0, 0.035), 2.0);
  float dc = max(dc1, -dc2)+0.0025;
  return dc;
}

float impulse_moon(vec2 p) {
  float dc5 = circle(p-vec2(-3.6, 1.45), 0.25);
  float dc6 = circle(p-vec2(-3.6, 1.45)+0.025*vec2(-1.0, 1.0), 0.25);
  float dc0 = max(dc5, -dc6);
  return dc0;
}


float impulse_stars(vec2 p, float ltime) {
  const float count = 27.0;
  const float radius = 5.0;
  vec2 pp = toPolar(p);
  pp.y += ltime*TAU/(count*2.0);
  float n = mod1(pp.y, TAU/count);
  p = toRect(pp);
  p -= vec2(radius, 0.0);
  float ds = (star(p, 0.35, 0.35));
  return ds;
}

float impulse_df(vec2 p, float s, float ltime, bool stars) {
  p /= s;

  float di = impulse(p);
  di = min(abs(di-0.0275) - 0.0155*pow(s, -0.25), di);
  float dp = impulse_planet(p);
  float dm = impulse_moon(p);
  float ds = impulse_stars(p, ltime);
  float d = di;
  d = min(d, dp);
  d = min(d, dm);
  if (stars) d = min(d, ds);
  return d*s;
}

float impulse_fbm(vec2 p) {
  vec2 op = p;
  const float aa   = 0.3;
  const float ff   = 2.03;
  const float tt   = PI/2.5;
  const float oo   = 1.93;

  float a = 1.0;
  float o = 0.4;
  float s = 0.0;
  float d = 0.0;

  p*=0.55;
  for (int i; i < 3;++i) {
    float nn = a*vnoise(p);
    s += nn;
    d += abs(a);
    p += o;
    a *= aa;
    p *= ff;
    o *= oo;
    rot(p, tt);
  }

  return 0.65*(s/d);
}

float impulse_warp(vec2 p, float ltime, out vec2 v, out vec2 w) {
  rot(p, -1.0);
  p.x += 0.75;

  vec2 o1 = vec2(1.0)*0.125;
  vec2 o2 = vec2(-1.0)*0.125;
  vec2 o3 = vec2(1.0)*0.125;
  vec2 o4 = vec2(-1.0)*0.125;
  rot(o1, ltime*sqrt(0.5));
  rot(o2, ltime*sqrt(0.45));
  rot(o3, -ltime*sqrt(0.35));
  rot(o4, -ltime);
  vec2 vv = vec2(impulse_fbm(p + o1), impulse_fbm(p + o2));
  vv *= -5.0;
  vec2 ww = vec2(impulse_fbm(p + vv + o2), impulse_fbm(p + vv + o3));
  ww *= -5.0;
  v = vv;
  w = ww;
  return impulse_fbm(p + ww + o4);
}

float impulse_height(vec2 p, float ltime) {
  vec2 v;
  vec2 w;
  return impulse_warp(p, ltime, v, w);
}

vec3 impulse_normal(vec2 p, float ltime) {
  vec2 v;
  vec2 w;
  vec2 e = vec2(0.00001, 0);

  vec3 n;
  n.x = impulse_height(p + e.xy, ltime) - impulse_height(p - e.xy, ltime);
  n.y = 2.0*e.x;
  n.z = impulse_height(p + e.yx, ltime) - impulse_height(p - e.yx, ltime);

  return normalize(n);
}

vec3 impulse_intro(float ltime, vec2 p, vec2 q) {
  // Hard coded to 7 fadein and fadeout
  float pixel = 5.0/RESOLUTION.y;
  float s = 30.0/(10.0 + ltime*(100.0/DURATION1));
  float d = impulse_df(p, s, ltime, true);
  vec2 op = p;
  vec3 col = vec3(0.0);
  p *= 0.5;
  p -= 0.2;

  vec2 v;
  vec2 w;

  float h = impulse_warp(p, ltime, v, w);
  vec3 n = impulse_normal(p, ltime);
  vec3 lp1 = vec3(-4.0, -2.0, 3.0);
  vec3 ld1 = normalize(vec3(p.x, h, p.y) - lp1);
  float dif1 = max(dot(n, ld1), 0.0);

  float vv = 0.8;

  vec3 col1 = hsv2rgb(vec3(0.95*v.yx, vv));
  vec3 col2 = hsv2rgb(vec3(-0.65*w, vv));

  col = (col1 + col2)*pow(dif1, 2.25);

  col = mix(col, vec3(1.0), smoothstep(0.0, pixel, -d));

  col = postProcess(col, q);

  float fadeIn  = smoothstep(0.0, 2.0, ltime);
  float fadeOut = smoothstep(DURATION1 - 4.0, DURATION1, ltime);

  col = col + (1.0 - fadeIn);
  col = mix(col, vec3(0.0), fadeOut*fadeOut);

  return col;
}

vec3 impulse_outro(float ltime, vec2 p, vec2 q) {
  float pixel = 5.0/RESOLUTION.y;
  float s = 10.0/(10.0 + 0.5*ltime*(3.0/DURATION));
  s *= 0.2;
  float d = impulse_df(p, s, ltime, false);

  vec3 col = vec3(0.0);
  col = mix(col, vec3(1.0), smoothstep(0.0, pixel, -d));

  col = postProcess(col, q);

  return col;
}

vec3 impulse_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  vec3 col = vec3(0.5);
  switch(minor) {
  case MINOR_INTRO:
    col = impulse_intro(ltime, p, q);
    break;
  case MINOR_OUTRO:
    col = impulse_outro(ltime, p, q);
    break;
  }
  return col;
}

#endif

// -----------------------------==> IMPULSE <==--------------------------------

// ------------------------------==> ORRERY <==--------------------------------

#ifdef ENABLE_ORRERY

const vec3  orrery_moonColor            = vec3(0.6, 0.5, 0.4);
const float orrery_farAway              = 1E6;
const vec4  orrery_vgasGiant            = vec4(0.0, 0.0, 0.0, 10);
const vec4  orrery_vmoon                = vec4(-19.0, 0.7, 0.0, 0.5);

vec3 orrery_skyColor(vec3 rd) {
  float diff = max(dot(rd, sunDirection), 0.0);
  float smallDiff = max(dot(rd, smallSunDirection), 0.0);

  vec3 col = vec3(0.0);
  col += pow(diff, 800.0)*sunColor1*8.0;
  col += pow(diff, 150.0)*sunColor2*1.0;

  col += pow(smallDiff, 10000.0)*smallSunColor1*1.0;
  col += pow(smallDiff, 1000.0)*smallSunColor2*0.25;
  col += pow(smallDiff, 400.0)*smallSunColor2*0.25;

  return col;
}

vec4 orrery_moon(float input0) {
  vec3 p = orrery_vmoon.xyz;
  rot(p.xz, input0);
  p.y *= pcos(input0);
  return vec4(p, orrery_vmoon.w);
}

vec4 orrery_rings(float input0, vec3 ro, vec3 rd, inout float pd) {
  float rsd = (0.0 - ro.y)/rd.y;
  vec3 p = ro + rd*rsd;

  vec3 pn = vec3(0.0, 1.0, 0.0);
  vec3 pr = reflect(rd, pn);
  vec3 pref = orrery_skyColor(pr);
  float pfres = pow(1.0-abs(dot(rd, pn)), 10.0);
  float pl = length(p);
  float pdf = pl-22.0;
  pdf = abs(pdf) - 3.2;
  pdf = abs(pdf) - 2.1;
  pdf = abs(pdf) - 1.0;
  vec4 pcol = vec4(1.0);
  pcol.xyz = mix(vec3(1.0, 0.8, 0.75), vec3(1.0, 1.0, 1.0), 0.5 - 0.5*cos(15.0*pl))*sunColor1;
  pcol.xyz = pow(pcol.xyz, vec3(0.75));
  pcol.w = psin(20.0*pl)*psin(14.0*pl)*psin(21.0*pl);
  pcol.w *= 0.5*step(pdf, 0.0);
  pcol.xyz += pfres*pref;

  vec3 rsn = vec3(0.0, 1.0, 0.0);

  pcol.w = pow(pcol.w, 1.0*pow(abs(dot(rd, rsn)), 0.4));

  vec2 psi1 = raySphere(p, sunDirection, orrery_vgasGiant);
  pcol.xyz *= (1.0  - smoothstep(0.0, 1.0, (psi1.y - psi1.x)/(2.0*orrery_vgasGiant.w)));

  vec4 vm = orrery_moon(input0);
  vec2 psi2 = raySphere(p, sunDirection, vm);
  pcol.xyz *= (1.0  - smoothstep(0.0, 1.0, (psi2.y - psi2.x)/(2.0*vm.w)));

  pd = mix(pd, rsd, pcol.w > 0.0);

  return pcol;
}

vec4 orrery_gasGiant(float input0, vec3 ro, vec3 rd, vec3 skyCol, inout float pd) {
  vec4 col = vec4(0.0);

  vec3 srsd = raySphereDensity(ro, rd, orrery_vgasGiant, orrery_farAway);
  vec2 si = srsd.xy;
  float sdens = srsd.z;
  vec3 sp = ro + rd*si.x;
  vec3 smp = ro + rd*(si.x+si.y)*0.5;
  float smd = length(smp)/orrery_vgasGiant.w;
  vec3 sn = normalize(sp - orrery_vgasGiant.xyz);
  vec3 sr = reflect(rd, sn);
  vec3 sref = orrery_skyColor(sr);
  float sfres = pow(1.0-abs(dot(rd, sn)), 15.0);
  float sdiff = max(dot(sunDirection, sn), 0.0);
  float sf = (si.y - si.x)/(2.0*orrery_vgasGiant.w);
  vec3 sbeer = exp(-90.0*sdens*vec3(0.30, 0.25, 0.22)*pow(smd, -3.0));
  float srayl = pow(1.0 - abs(dot(rd, sn)), 5.0);

  float slo = atan(sp.z, sp.x);
  float slat = PI*sp.y/orrery_vgasGiant.w;
  vec3 scol = vec3(0.8);

  scol = mix(scol, vec3(0.7, 0.7, 0.8), pow(pcos(20.0*slat), 5.0));
  scol = mix(scol, vec3(0.75, 0.7, 0.8), pow(pcos(14.0*slat), 20.0));
  scol = mix(scol, vec3(0.2), pow(pcos(21.0*slat)*pcos(13.0*slat+1.0), 15.0));
  scol = tanh(scol);
  scol *= pow(sunColor1, vec3(0.66));
  scol += vec3(0.0, 0.0, srayl*0.5) ;

  vec4 vm = orrery_moon(input0);
  vec2 mi = raySphere(sp, sunDirection, vm);

  float msha = (1.0  - smoothstep(0.0, 1.0, (mi.y - mi.x)/(2.0*vm.w)));

  if (si.x < si.y) {
    col.xyz = sfres*sref + pow(skyCol, vec3(0.85))*sbeer + scol*pow(sdiff, 0.75);
    col.xyz *= msha;
    col.w = 1.0;
    pd = si.x;
  }

  return col;
}

vec4 orrery_moon(float input0, vec3 ro, vec3 rd, vec3 skyCol, inout float pd) {
  vec4 col = vec4(0.0);

  vec4 vm = orrery_moon(input0);

  vec2 si = raySphere(ro, rd, vm);
  vec3 sp = ro + rd*si.x;
  vec3 sn = normalize(sp - vm.xyz);
  float sdiff = max(dot(sunDirection, sn), 0.0);
  vec3 sr = reflect(rd, sn);
  vec3 sref = orrery_skyColor(sr);
  float sfres = pow(1.0-abs(dot(rd, sn)), 5.0);
  float sf = (si.y - si.x)/(2.0*vm.w);

  vec2 gi = raySphere(sp, sunDirection, orrery_vgasGiant);

  float gsha = (1.0  - smoothstep(0.0, 1.0, (gi.y - gi.x)/(2.0*orrery_vgasGiant.w)));

  if (si.x < si.y) {
    col.xyz = sfres*sref + orrery_moonColor*pow(sdiff, 0.75);
    col.w = (1.0 - exp(-7.0*sf))*gsha;
    pd = si.x;
  }

  return col;
}

vec4 orrery_ship(float ltime, float input0, float input1, vec3 ro, vec3 rd, vec3 skyCol, inout float pd) {
  const vec3 normal = normalize(-vec3(-1.0, -1.0, -1.0));
  const vec3 up = normalize(vec3(0.0, 1.0, 0.0));
  const vec3 xx = cross(up, normal);
  const vec3 yy = cross(xx, normal);
  const float exc = 0.1;

  vec4 vm = orrery_moon(input0);

  vec4 p = vec4(normal, -dot(normal, vm.xyz));
  float d = rayPlane(ro, rd, p);
  vec3 pp = ro + rd*d - vm.xyz;

  vec2 p2 = vec2(dot(xx, pp), dot(yy, pp));
  p2.y *= -1.0;
  p2 += vec2(0.0, 2.0*vm.w);

  const float posY = 0.15;
  const float posX = sqrt(posY/exc);

  float dp = parabola(p2, exc);
  dp = abs(dp)-0.001;

  float trailt = smoothstep(0.0125+p2.y*p2.y*0.01, 0.0, dp);

  float fadeOut = (smoothstep(10.0, posY, p2.y));

  trailt *= fadeOut*(step(posY, p2.y))*step(p2.x, 0.0);
  trailt *= 1.5-1.0*smoothstep(0.0, 0.75, p2.y);

  vec4 trailCol = vec4(hsv2rgb(vec3(0.99, 0.0, 1.0)-vec3(0.5, -1.0, 0.5)*(1.0-fadeOut)), trailt);

  float sc = circle(p2-vec2(-posX, posY), 0.0);

  vec4 shipCol = vec4(2.0*vec3(1.5, 1.0, 2.0), 1.0)*smoothstep(-7.0, 1.0, sin(ltime*4.0*TAU))*smoothstep(0.125, 0.0, sc);

  vec4 col = mix(trailCol, shipCol, shipCol.w)*input1;

  pd = mix(pd, d, col.w > 0.0);


  return col;
}

vec3 orrery_render(float ltime, float input0, float input1, vec3 ro, vec3 rd) {
  vec3 skyCol = orrery_skyColor(rd);

  vec4 col = vec4(skyCol, 1.0);
  float cold = orrery_farAway;

  vec4 ggcol = orrery_gasGiant(input0, ro, rd, skyCol, cold);

  col.xyz = mix(col.xyz, ggcol.xyz, ggcol.w);

  float md = orrery_farAway;
  vec4 mcol = orrery_moon(input0, ro, rd, skyCol, md);

  col.xyz = mix(col.xyz, mcol.xyz, mcol.w*step(md, cold));
  cold = mix(cold, md, step(md, cold));

  float rsd = orrery_farAway;
  vec3 rsp;
  vec4 rscol = orrery_rings(input0, ro, rd, rsd);

  col.xyz = mix(col.xyz, rscol.xyz, rscol.w*step(rsd, cold));
  cold = mix(cold, rsd, step(rsd, cold));

  float sd = orrery_farAway;
  vec4 scol = orrery_ship(ltime, input0, input1, ro, rd, skyCol, sd);

  col.xyz = mix(col.xyz, scol.xyz, scol.w*step(sd, cold));
  cold = mix(cold, sd, step(sd, cold));

  return col.xyz;
}

vec3 orrery_fragment(float ltime, float input0, float input1, vec3 ro, vec3 uu, vec3 vv, vec3 ww, vec2 p) {
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.5*ww);
  vec3 col = orrery_render(ltime, input0, input1, ro, rd);
  return col;
}

vec3 orrery_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  vec3 ro = vec3(0.0, 0.0, 52.0);
  vec3 la = vec3(0.0, 0.0,0.0);
  vec3 up = vec3(-0.0, 1.0, 0.0);

  switch(minor) {
  case MINOR_SUNRISE:
    ro.y += ltime*4.0/(2.0*DURATION)+3.0;
    la = vec3(0.0, 0.0, -orrery_farAway);
    break;
  case MINOR_CLOSEUP:
    ro = vec3(0.0, 0.0, -25.0);
    rot(ro.yz, 1.0-0.1*ltime/(2.0*DURATION));
    la = vec3(0.0, 0.0, 0.0);
    up = vec3(-0.25, 1.0, 0.0);
    break;
  case MINOR_APPROACH:
    ro = (0.75-ltime/(3.0*DURATION)*0.15)*vec3(-25.0, -20.0, -40.0);
    la = orrery_moon(input0).xyz;
    break;
  case MINOR_ESCAPE:
    ro = vec3(0.0, 5.0, 30.0);
    la = vec3(0.0, 0.0, -orrery_farAway);
    ro.x += -6.0*ltime/(3.0*DURATION);
    ro.y += 12.0*ltime/(3.0*DURATION);
    ro.z += 60.0*ltime/(3.0*DURATION);
    up = vec3(-1.0, 1.0, 0.0);
    break;
  default:
    break;
  }



  vec3 ww = normalize(la - ro);
  vec3 uu = normalize(cross(up, ww));
  vec3 vv = normalize(cross(ww,uu));

  float s = 2.0/RESOLUTION.y;

  vec2 o1 = vec2(1.0/8.0, 3.0/8.0)*s;
  vec2 o2 = vec2(-3.0/8.0, 1.0/8.0)*s;

  vec3 col = vec3(0.0);

  // https://blog.demofox.org/2015/04/23/4-rook-antialiasing-rgss/
  col += orrery_fragment(ltime, input0, input1, ro, uu, vv, ww, p+o1);

  col = clamp(col, 0.0, 1.0);

  // Adaptive AA? Is that a good idea?
  vec3 dcolx = dFdx(col);
  vec3 dcoly = dFdy(col);
  vec3 dcol = sqrt(dcolx*dcolx+dcoly*dcoly)/(col+0.01);
//  vec3 dcol = sqrt(dcolx*dcolx+dcoly*dcoly);

  float de = max(dcol.x, max(dcol.y, dcol.z));

  if (de > 0.1) {
    col += orrery_fragment(ltime, input0, input1, ro, uu, vv, ww, p-o1);
    col += orrery_fragment(ltime, input0, input1, ro, uu, vv, ww, p+o2);
    col += orrery_fragment(ltime, input0, input1, ro, uu, vv, ww, p-o2);
    col *=0.25;
//    col = vec3(1.0, 0.0, 0.0);
  }

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> ORRERY <==--------------------------------

// ----------------------------==> WATERWORLD <==------------------------------

#ifdef ENABLE_WATERWORLD

#define WATERWORLD_TOLERANCE       0.00001
#define WATERWORLD_MAX_ITER        55
#define WATERWORLD_MAX_DISTANCE    31.0

float waterworld_heightMod(vec2 p) {
  vec2 pp = toPolar(p);
  pp.y += -pp.x*0.2;
  p = toRect(pp);
  return pow((psin(1.0*p.x)*psin(1.0*p.y)), max(0.25, pp.x*0.20))*0.8;
}

float waterworld_height(vec2 p, float dd, int mx) {
  const float aa   = 0.5;
  const float ff   = 2.03;
  const float tt   = 1.3;
  const float oo   = 0.93;

  float hm = waterworld_heightMod(p);

  vec2 s = vec2(0.0);
  float a = 1.0;
  float o = 0.2;

  int i = 0;

  p *= 2.0;

  for (; i < mx;++i) {
    float nn = a*(vnoise(p));
    s.x += nn;
    s.y += abs(a);
    p += o;
    a *= aa;
    p *= ff;
    o *= oo;
    rot(p, tt);
  }

  s.x /= s.y;
  s.x -= 1.0;
  s.x += 0.7*hm;
  s.x = smoother(s.x, 0.125);

  return max(s.x+0.125, 0.0)*0.5;
}

float waterworld_loheight(vec2 p, float d) {
  return waterworld_height(p, d, 3);
}

float waterworld_height(vec2 p, float d) {
  return waterworld_height(p, d, 5);
}

float waterworld_hiheight(vec2 p, float d) {
  return waterworld_height(p, d, 6);
}

vec3 waterworld_normal(vec2 p, float d) {
  vec2 eps = vec2(0.000125, 0.0);

  vec3 n;

  n.x = (waterworld_hiheight(p - eps.xy, d) - waterworld_hiheight(p + eps.xy, d));
  n.y = 2.0*eps.x;
  n.z = (waterworld_hiheight(p - eps.yx, d) - waterworld_hiheight(p + eps.yx, d));

  return normalize(n);
}

float waterworld_march(vec3 ro, vec3 rd, float id, out int max_iter) {
  float dt = 0.1;
  float d = id;
  int currentStep = 0;
  float lastd = d;
  for (int i = 0; i < WATERWORLD_MAX_ITER; ++i) {
    vec3 p = ro + d*rd;
    float h = waterworld_height(p.xz, d);

    if (d > WATERWORLD_MAX_DISTANCE) {
      max_iter = i;
      return WATERWORLD_MAX_DISTANCE;
    }

    float hd = p.y - h;

    if (hd < WATERWORLD_TOLERANCE) {
      return d;
    }

    const float sl = 0.9;

    dt = max(hd*sl, WATERWORLD_TOLERANCE+0.0005*d);
    lastd = d;
    d += dt;
  }

  max_iter = WATERWORLD_MAX_ITER;
  return WATERWORLD_MAX_DISTANCE;
}

vec3 waterworld_sunDirection() {
  return normalize(vec3(-0.5, 0.2, 1.0));
}

vec3 waterworld_smallSunDirection() {
  return normalize(vec3(-0.2, -0.05, 1.0));
}

vec3 waterworld_skyColor(vec3 ro, vec3 rd) {
  vec3 sunDir = waterworld_sunDirection();
  vec3 smallSunDir = waterworld_smallSunDirection();

  float sunDot = max(dot(rd, sunDir), 0.0);
  float smallSunDot = max(dot(rd, smallSunDir), 0.0);

  float angle = atan(rd.y, length(rd.xz))*2.0/PI;

  vec3 sunCol = 0.5*sunCol1*pow(sunDot, 20.0) + 8.0*sunCol2*pow(sunDot, 2000.0);
  vec3 smallSunCol = 0.5*smallSunCol1*pow(smallSunDot, 200.0) + 8.0*smallSunCol2*pow(smallSunDot, 20000.0);

  float dustTransparency = smoothstep(-0.15, 0.075, rd.y);

  vec3 skyCol = mix(skyCol1, skyCol2, sqrt(dustTransparency));
  skyCol *= (1.0-dustTransparency);

  vec3 planetCol = gasGiant(ro, rd, sunDir)*dustTransparency;

  vec3 final = planetCol + skyCol + sunCol + smallSunCol;

  return final;
}

vec3 waterworld_shipColor(vec2 p, float ltime) {
  vec2 pp = toPolar(p);
  pp.y += pp.x*0.05;
  p = toRect(pp);

  float n = mod1(p.x, 0.15);
  p.y += 3.0-ltime*0.5+0.05*abs(n*n);

  float td = abs(p.x) - (0.005-p.y*0.002);
  td = abs(td) - (0.02*pow(-p.y, 0.25));
  float sd = circle(p, 0.05);

  vec3 trailCol = vec3(0.5)*smoothstep(-5.0, 0.0, p.y)*step(p.y, 0.0)*smoothstep(0.0, 0.025, -td);
  vec3 shipCol = vec3(0.5+smoothstep(-1.0, 1.0, sin(ltime*15.0*TAU+n)))*smoothstep(0.0, 0.075, -sd);

  vec3 col = trailCol;
  col += shipCol;

  float sm = step(abs(n), 2.0);

  return col*sm;
}

vec3 waterworld_getColor(vec3 ro, vec3 rd, float ltime) {
  int max_iter = 0;
  vec3 skyCol = waterworld_skyColor(ro, rd);
  vec3 col = vec3(0);

  const float shipHeight = 1.0;
  const float seaHeight = 0.0;
  const float cloudHeight = 0.2;
  const float upperCloudHeight = 0.5;

  float id = (cloudHeight - ro.y)/rd.y;

  if (id > 0.0) {
    float d = waterworld_march(ro, rd, id, max_iter);
    vec3 sunDir = waterworld_sunDirection();
    vec3 osunDir = sunDir*vec3(-1.0, 1.0, -1.0);
    vec3 p = ro + d*rd;

    float loh = waterworld_loheight(p.xz, d);
    float loh2 = waterworld_loheight(p.xz+sunDir.xz*0.05, d);
    float hih = waterworld_hiheight(p.xz, d);
    vec3 normal = waterworld_normal(p.xz, d);

    float ud = (upperCloudHeight - 4.0*loh - ro.y)/rd.y;

    float sd = (seaHeight - ro.y)/rd.y;
    vec3 sp = ro + sd*rd;
    float scd = (cloudHeight - sp.y)/sunDir.y;
    vec3 scp = sp + sunDir*scd;

    float sloh = waterworld_loheight(scp.xz, d);
    float cshd = exp(-15.0*sloh);

    float amb = 0.3;

    vec3 seaNormal = normalize(vec3(0.0, 1.0, 0.0));
    vec3 seaRef = reflect(rd, seaNormal);
    vec3 seaCol = .25*waterworld_skyColor(p, seaRef);
    seaCol += pow(max(dot(seaNormal, sunDir), 0.0), 2.0);
    seaCol *= cshd;
    seaCol += 0.075*pow(vec3(0.1, 1.3, 4.0), vec3(max(dot(seaNormal, seaRef), 0.0)));

    float spe = pow(max(dot(sunDir, reflect(rd, normal)), 0.0), 3.0);
    float fre = pow(1.0-dot(normal, -rd), 2.0);

    col = seaCol;

    const float level = 0.00;
    const float level2 = 0.3;
    // REALLY fake shadows and lighting
    vec3 scol = sunCol1*(smoothstep(level, level2, hih) - smoothstep(level, level2, loh2));
    col = mix(vec3(1.0), col, exp(-17.0*(hih-0.25*loh)));
    col = mix(vec3(0.75), col, exp(-10.0*loh*(max(d-ud, 0.0))));
    col += scol;

    col += vec3(0.5)*spe*fre;

    float ssd = (shipHeight - ro.y)/rd.y;

    col += waterworld_shipColor((ro + rd*ssd).xz, ltime);

    col = mix(col, skyCol, smoothstep(0.5*WATERWORLD_MAX_DISTANCE, 1.*WATERWORLD_MAX_DISTANCE, d));

  } else {
    col = skyCol;
  }

//  col += vec3(1.1, 0.0, 0.0)* smoothstep(0.25, 1.0,(float(max_iter)/float(MAX_ITER)));
  return col;
}

vec3 waterworld_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  vec3 ro  = vec3(0.5, 5.5, -2.0);
  vec3 la  = ro + vec3(0.0, -1.+0.75*ltime/(4.0*DURATION),  1.0);

  vec3 ww = normalize(la - ro);
  vec3 uu = normalize(cross(vec3(0.0,1.0,0.0), ww));
  vec3 vv = normalize(cross(ww, uu));
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.0*ww);

  vec3 col = waterworld_getColor(ro, rd, ltime)  ;

  col = postProcess(col, q);

  return col;
}

#endif

//


// ----------------------------==> WATERWORLD <==------------------------------

// ----------------------------==> BARRENMOON <==------------------------------

#ifdef ENABLE_BARRENMOON

#define BARRENMOON_TOLERANCE       0.00001
#define BARRENMOON_MAX_ITER        65
#define BARRENMOON_MIN_DISTANCE    0.01
#define BARRENMOON_MAX_DISTANCE    9.0

const float barrenmoon_near = 0.3;
const float barrenmoon_far  = 0.5;

const vec3 barrenmoon_sunCol1      = pow(sunCol1, vec3(1.0, 4.0, 4.0));
const vec3 barrenmoon_sunCol2      = pow(sunCol2, vec3(2));
const vec3 barrenmoon_smallSunCol1 = smallSunCol1;
const vec3 barrenmoon_smallSunCol2 = smallSunCol2;

vec2 barrenmoon_hash(vec2 p) {
  p = vec2(dot (p, vec2 (127.1, 311.7)), dot (p, vec2 (269.5, 183.3)));
  return -1. + 2.*fract (sin (p)*43758.5453123);
}

float barrenmoon_circles(vec2 p) {
  vec2 n = mod2_1(p);
  vec2 hh = barrenmoon_hash(sqrt(2.0)*(n+1000.0));
  hh.x *= hh.y;

  const float r = 0.225;

  float d = circle(p, 2.0*r);

  float h = hh.x*smoothstep(0.0, r, -d);

  return h*0.25;
}

float barrenmoon_craters(vec2 p) {
  vec2 n = mod2_1(p);
  vec2 hh = barrenmoon_hash(sqrt(2.0)*(n+1000.0));
  hh.x *= hh.y;

  rot(p, TAU*hh.y);
  const float r = 0.45;

  float d = egg(p, 0.75*r, 0.5*r*abs(hh.y));

  float h = -abs(hh.x)*(smoothstep(0.0, r, -2.0*d)-0.3*smoothstep(0.0, 0.2*r, -d));

  return h*0.275;
}


float barrenmoon_height(vec2 p, float dd, int mx) {
  const float aa   = 0.45;
  const float ff   = 2.03;
  const float tt   = 1.2;
  const float oo   = 3.93;

  float a = 1.0;
  float o = 0.2;
  float s = 0.075*sin(p.x+p.y);
  float d = 0.0;

  int i = 0;

  for (; i < 4;++i) {
    float nn = a*barrenmoon_craters(p);
    s += nn;
    d += abs(a);
    p += o;
    a *= aa;
    p *= ff;
    o *= oo;
    rot(p, tt);
  }

  float lod = s/d;

  float rdd = dd/BARRENMOON_MAX_DISTANCE;
  mx = int(mix(float(4), float(mx), step(rdd, barrenmoon_far)));

  for (; i < mx; ++i) {
    float nn = a*barrenmoon_circles(p);
    s += nn;
    d += abs(a);
    p += o;
    a *= aa;
    p *= ff;
    o *= oo;
    rot(p, tt);
  }

  float hid = (s/d);

  float m = smoothstep(barrenmoon_near, barrenmoon_far, rdd);
  return mix(hid, lod, m*m);
}

float barrenmoon_height(vec2 p, float d) {
  return barrenmoon_height(p, d, 6);
}

float barrenmoon_hiheight(vec2 p, float d) {
  return barrenmoon_height(p, d, 8);
}

vec3 barrenmoon_normal(vec2 p, float d) {
  vec2 eps = vec2(0.000125, 0.0);

  vec3 n;

  n.x = (barrenmoon_hiheight(p - eps.xy, d) - barrenmoon_hiheight(p + eps.xy, d));
  n.y = 2.0*eps.x;
  n.z = (barrenmoon_hiheight(p - eps.yx, d) - barrenmoon_hiheight(p + eps.yx, d));

  return normalize(n);
}

float barrenmoon_march(vec3 ro, vec3 rd, float id, out int max_iter) {
  float dt = 0.1;
  float d = id;
  const float initialStep = 1.0;
  const float secondaryStep = 0.25;
  float currentStepDist = initialStep;
  float lastd = d;
  float mint = -0.005/rd.y;
  for (int i = 0; i < BARRENMOON_MAX_ITER; ++i) {
    vec3 p = ro + d*rd;
    float h = barrenmoon_height(p.xz, d);

    if (d > BARRENMOON_MAX_DISTANCE) {
      max_iter = i;
      return BARRENMOON_MAX_DISTANCE;
    }

    float hd = p.y - h;

    if (hd < BARRENMOON_TOLERANCE) {
      if (currentStepDist < initialStep) {
        max_iter = i;
        return d;
      }

      d = lastd;
      currentStepDist = secondaryStep;
      continue;
    }

    dt = max(hd, mint)*currentStepDist;
    lastd = d;
    d += dt;
  }

  max_iter = BARRENMOON_MAX_ITER;
  return BARRENMOON_MAX_DISTANCE;
}

vec3 barrenmoon_sunDirection() {
  return normalize(vec3(-0.5, 0.085, 1.0));
}

vec3 barrenmoon_smallSunDirection() {
  return normalize(vec3(-0.2, -0.05, 1.0));
}

vec3 barrenmoon_rocketDirection(float ltime) {
  return normalize(vec3(0.0, -0.2+mod(ltime, 90.0)*0.0125, 1.0));
}

vec3 barrenmoon_skyColor(float ltime, vec3 ro, vec3 rd) {
  vec3 sunDir = barrenmoon_sunDirection();
  vec3 smallSunDir = barrenmoon_smallSunDirection();

  float sunDot = max(dot(rd, sunDir), 0.0);
  float smallSunDot = max(dot(rd, smallSunDir), 0.0);

  float angle = atan(rd.y, length(rd.xz))*2.0/PI;

  vec3 skyCol = mix(mix(skyCol1, vec3(0.0), smoothstep(0.0 , 1.0, 5.0*angle)), skyCol3, smoothstep(0.0, 1.0, -5.0*angle));

  vec3 sunCol = 0.5*barrenmoon_sunCol1*pow(sunDot, 20.0) + 8.0*barrenmoon_sunCol2*pow(sunDot, 2000.0);
  vec3 smallSunCol = 0.5*barrenmoon_smallSunCol1*pow(smallSunDot, 200.0) + 4.0*barrenmoon_smallSunCol2*pow(smallSunDot, 20000.0);

  vec3 dust = pow(barrenmoon_sunCol2*mountainColor, vec3(1.75))*smoothstep(0.05, -0.1, rd.y)*0.5;

  vec2 si = raySphere(ro, rd, planet);
  float pi = rayPlane(ro, rd, rings);

  float dustTransparency = smoothstep(-0.075, 0.0, rd.y);

  vec3 rocketDir = barrenmoon_rocketDirection(ltime);
  float rocketDot = max(dot(rd, rocketDir), 0.0);
  float rocketDot2 = max(dot(normalize(rd.xz), normalize(rocketDir.xz)), 0.0);
  vec3 rocketCol = vec3(0.25)*(3.0*smoothstep(-1.0, 1.0, psin(ltime*15.0*TAU))*pow(rocketDot, 70000.0) + smoothstep(-0.25, 0.0, rd.y - rocketDir.y)*step(rd.y, rocketDir.y)*pow(rocketDot2, 1000000.0))*dustTransparency;

  vec3 planetCol = gasGiant(ro, rd, sunDir)*dustTransparency;

  vec3 final = planetCol + skyCol + sunCol + smallSunCol + dust + rocketCol;

  return final;
}

vec3 barrenmoon_getColor(float ltime, vec3 ro, vec3 rd) {
  int max_iter = 0;
  vec3 skyCol = barrenmoon_skyColor(ltime, ro, rd);
  vec3 col = vec3(0);

  float id = (0.125 - ro.y)/rd.y;

  if (id > 0.0)   {
    float d = barrenmoon_march(ro, rd, id, max_iter);
    vec3 sunDir = barrenmoon_sunDirection();
    vec3 osunDir = sunDir*vec3(-1.0, .0, -1.0);
    vec3 p = ro + d*rd;

    vec3 normal = barrenmoon_normal(p.xz, d);
    vec3 dnx = dFdx(normal);
    vec3 dny = dFdy(normal);
    float ff = dot(dnx, dnx) + dot(dny, dny);
    normal = normalize(normal+ vec3(0.0, 5.0*ff, 0.0));

    float amb = 0.2;

    float dif1 = max(0.0, dot(sunDir, normal));
    vec3 shd1 = barrenmoon_sunCol2*mix(amb, 1.0, pow(dif1, 0.75));

    float dif2 = max(0.0, dot(osunDir, normal));
    vec3 shd2 = barrenmoon_sunCol1*mix(amb, 1.0, pow(dif2, 0.75));

    vec3 ref = reflect(rd, normal);
    vec3 rcol = barrenmoon_skyColor(ltime, p, ref);

    col = mountainColor*amb*skyCol3;
    col += mix(shd1, shd2, -0.5)*mountainColor;
    float fre = max(dot(normal, -rd), 0.0);
    fre = pow(1.0 - fre, 5.0);
    col += rcol*fre*0.5;
    col += (1.0*p.y);
    col = tanh(col);
    col = mix(col, skyCol, smoothstep(0.5*BARRENMOON_MAX_DISTANCE, BARRENMOON_MAX_DISTANCE, d));

  } else {
    col = skyCol;
  }
//  col += vec3(1.1, 0.0, 0.0)* smoothstep(0.25, 1.0,(float(max_iter)/float(MAX_ITER)));
  return col;
}

vec3 barrenmoon_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  ltime = ltime + input0;
  float off = 0.5*ltime;

  vec3 ro  = vec3(0.5, 1.0-0.25, -2.0 + off);
  vec3 la  = ro + vec3(0.0, -0.00,  2.0);

  vec3 ww = normalize(la - ro);
  vec3 uu = normalize(cross(vec3(0.0,1.0,0.0), ww));
  vec3 vv = normalize(cross(ww, uu));
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.0*ww);

  vec3 col = barrenmoon_getColor(ltime, ro, rd)  ;

//  col = postProcess(col, q);

  return col;
}

#endif

// ----------------------------==> BARRENMOON <==------------------------------

// ------------------------------==> GALAXY <==--------------------------------

#ifdef ENABLE_GALAXY

const float galaxy_twirly   = 2.5;
const vec3  galaxy_colDust  = vec3(1.0, 0.9, 0.75);

float galaxy_noise(float ttime, vec2 p) {
  float s = 1.0;

  p *= tanh(0.1*length(p));
  float tm = ttime;

  float a = cos(p.x);
  float b = cos(p.y);

  float c = cos(p.x*sqrt(3.5)+tm);
  float d = cos(p.y*sqrt(1.5)+tm);

  return a*b*c*d;
}

vec2 galaxy_twirl(vec2 p, float a, float z) {
  vec2 pp = toPolar(p);
  pp.y += pp.x*galaxy_twirly + a;
  p = toRect(pp);

  p *= z;

  return p;
}

float galaxy_galaxy(float ttime, vec2 p, float a, float z) {
  p = galaxy_twirl(p, a, z);

  return galaxy_noise(ttime, p);
}

vec3 galaxy_stars(vec2 p) {
  float l = length(p);

  vec2 pp = toPolar(p);
  pp.x /= (1.0+length(pp.x))*0.5;
  p = toRect(pp);

  float sz = 0.0075;

  vec3 s = vec3(10000.0);

  for (int i = 0; i < 3; ++i) {
    rot(p, 0.5);
    vec2 ip = p;
    vec2 n = mod2(ip, vec2(sz));
    float r = hash(n);
    vec2 o = -1.0 + 2.0*vec2(r, fract(r*1000.0));
    s.x = min(s.x, length(ip-0.25*sz*o));
    s.yz = n*0.1;
  }

  return s;
}

float galaxy_height(float ttime, vec2 p) {
  float ang = atan(p.y, p.x);
  float l = length(p);
  float sp = mix(1.0, pow(0.75 + 0.25*sin(2.0*(ang + l*galaxy_twirly)), 3.0), tanh(6.0*l));
  float s = 0.0;
  float a = 1.0;
  float f = 15.0;
  float d = 0.0;
  for (int i = 0; i < 11; ++i) {
    float g = a*galaxy_galaxy(ttime, p, ttime*(0.025*float(i)), f);
    s += g;
    a *= sqrt(0.45);
    f *= sqrt(2.0);
    d += a;
  }

  s *= sp;

  return SABS((-0.25+ s/d), 0.5)*exp(-5.5*l*l);
}

vec3 galaxy_normal(float ttime, vec2 p) {
  vec2 eps = vec2(0.000125, 0.0);

  vec3 n;

  n.x = galaxy_height(ttime, p - eps.xy) - galaxy_height(ttime, p + eps.xy);
  n.y = 2.0*eps.x;
  n.z = galaxy_height(ttime, p - eps.yx) - galaxy_height(ttime, p + eps.yx);

  return normalize(n);
}

vec3 galaxy_galaxy(float ttime, vec2 p, vec3 ro, vec3 rd, float d) {
  rot(p, 0.5*ttime);

  float h = galaxy_height(ttime, p);
  vec3 s = galaxy_stars(p);
  float th = tanh(h);
  vec3 n = galaxy_normal(ttime, p);

  vec3 p3 = vec3(p.x, th, p.y);
  float lh = 0.5;
  vec3 lp1 = vec3(-0.0, lh, 0.0);
  vec3 ld1 = normalize(lp1 - p3);
  vec3 lp2 = vec3(0.0, lh, 0.0);
  vec3 ld2 = normalize(lp2 - p3);

  float l = length(p);
  float tl = tanh(l);

  float diff1 = max(dot(ld1, n), 0.0);
  float diff2 = max(dot(ld2, n), 0.0);

  vec3 col = vec3(0.0);
  col += vec3(0.5, 0.5, 0.75)*h;
//  col += vec3(0.5)*pow(diff1, 20.0);
  col += 0.25*pow(diff2, 4.0);
  col += pow(vec3(0.5)*h, n.y*1.75*(mix(vec3(0.5, 1.0, 1.5), vec3(0.5, 1.0, 1.5).zyx, 1.25*tl)));
//  col += 0.9*vec3(1.0, 0.9, 0.75)*exp(-10*l*l);


  float sr = hash(s.yz);
  float si = pow(th*sr, 0.25)*0.001;
  vec3 scol = sr*5.0*exp(-2.5*l*l)*tanh(pow(si/(s.x), 2.5))*mix(vec3(0.5, 0.75, 1.0), vec3(1.0, 0.75, 0.5), sr*0.6);
  float sd = length(ro);
  scol = clamp(scol, 0.0, 1.0);
  col += step(sd, 1.5)*scol*smoothstep(0.0, 0.35, 1.0-n.y);

  float ddust = (h - ro.y)/rd.y;
  if (ddust < d) {
    float t = d - ddust;
    col += 0.7*galaxy_colDust*(1.0-exp(-2.0*t));
  }

  return col;
}

vec3 galaxy_render(float ttime, vec3 ro, vec3 rd) {
  float dgalaxy = (0.0 - ro.y)/rd.y;

  vec3 col = vec3(0);

  if (dgalaxy > 0.0) {
    col = vec3(0.5);
    vec3 p = ro + dgalaxy*rd;

    col = galaxy_galaxy(ttime, p.xz, ro, rd, dgalaxy);
  }

  vec2 cgalaxy = raySphere(ro, rd, vec4(vec3(0.0), 0.125));

  float t;

  if (dgalaxy > 0.0 && cgalaxy.x > 0.0) {
    float t0 = max(dgalaxy - cgalaxy.x, 0.0);
    float t1 = cgalaxy.y - cgalaxy.x;
    t = min(t0, t1);
  } else if (cgalaxy.x < cgalaxy.y){
    t = cgalaxy.y - cgalaxy.x;
  }

  col += 1.7*galaxy_colDust*(1.0-exp(-1.0*t));


  return col;
}

vec3 galaxy_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {
  vec3 ro = vec3(0.0, 0.7, 2.0)*mix(input0, input1, ltime/(2.0*DURATION));
  vec3 la = vec3(0.0, 0.0, 0.0);
  vec3 up = vec3(-0.5, 1.0, 0.0);
  vec3 ww = normalize(la - ro);
  vec3 uu = normalize(cross(up, ww));
  vec3 vv = normalize(cross(ww,uu));
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.5*ww);

  float ttime = 0.05*ltime;
  vec3 col = galaxy_render(ttime, ro, rd);

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> GALAXY <==--------------------------------

// -----------------------------==> SPACESHIP <==------------------------------

#ifdef ENABLE_SPACESHIP

#define SPACESHIP_TOLERANCE           0.001
#define SPACESHIP_NORM_OFF            0.001
#define SPACESHIP_MAX_RAY_LENGTH      100.0

#define SPACESHIP_MAX_RAY_MARCHES     60

const float spaceship_refractRatio = 0.95;

const vec3  spaceship_seaCol1      = vec3(0.15, 0.45, 0.55);
const vec3  spaceship_seaCol2      = spaceship_seaCol1*spaceship_seaCol1*spaceship_seaCol1*3.0;

const float spaceship_innerLength  = 4.0;
const float spaceship_outerLength  = 6.25;
const vec3  spaceship_sunPos       = vec3(0.0, 0.0, spaceship_innerLength);
const vec3  spaceship_sunCol1      = vec3(8.0/8.0,7.0/8.0,6.0/8.0);
const vec3  spaceship_sunCol2      = vec3(8.0/8.0,6.0/8.0,7.0/8.0);
const vec3  spaceship_engineCol1   = vec3(8.0/8.0,6.0/8.0,6.0/8.0);
const vec3  spaceship_engineCol2   = vec3(8.0/8.0,5.0/8.0,6.0/8.0);

const vec3  spaceship_start       = vec3(0.0);

vec3 spaceship_sunColor(vec3 ro, vec3 rd, float input0, float input1) {
  float diff = max(dot(rd, sunDirection), 0.0);
  float smallDiff = max(dot(rd, smallSunDirection), 0.0);
  vec3 col = vec3(0.0);

  col += pow(diff, 800.0)*sunColor1*8.0;
  col += pow(diff, 150.0)*sunColor2;

  col += pow(smallDiff, 8000.0)*smallSunColor1*1.0;
  col += pow(smallDiff, 400.0)*smallSunColor2*0.5;
  col += pow(smallDiff, 150.0)*smallSunColor2*0.5;

  return col;
}

vec3 spaceship_skyColor(vec3 ro, vec3 rd, float input0, float input1) {
  rot(rd.xz, input0);
  vec3 scol = spaceship_sunColor(ro, rd, input0, input1);
  vec3 gcol = gasGiant(ro+vec3(input0*input1/TAU, 0.0, input1), rd, sunDirection);

  return scol+gcol;
}

vec3 spaceship_refColor(vec3 ro, vec3 rd, float input0, float input1) {
  rot(rd.xz, input0);
  vec3 scol = spaceship_sunColor(ro, rd, input0, input1);

  vec3 final = vec3(0.0);
  if ((rd.y > abs(rd.x)*1.0) && (rd.y > abs(rd.z*0.25))) final = vec3(2.0)*rd.y;
  float roundBox = length(max(abs(rd.xz/max(0.0,rd.y))-vec2(0.9, 4.0),0.0))-0.1;
  final += vec3(0.8)* pow(saturate(1.0 - roundBox*0.5), 6.0);
  final *= 0.5;
  final += scol;

  return final;
}

vec3 spaceship_domeColor(vec3 ro, vec3 rd, float input0, float input1) {
  rot(rd.xz, input0);
  vec3 scol = spaceship_sunColor(ro, rd, input0, input1);

  vec3 final = mix(vec3(0.125, 0.25, 0.5), vec3(0.25), 0.5 + 0.5*rd.y)*0.5;
  final += scol;

  return final;
}

vec4 spaceship_backplane(vec3 ro, vec3 rd, inout vec3 scol) {
  float ed = (spaceship_innerLength - ro.z)/rd.z;
  vec3 ep = ro + rd*ed;
  vec3 en = vec3(0.0, 0.0, 1.0);

  float lr = 0.5;
  float er = (lr*lr-dot(ep.xy, ep.xy))/(lr*lr);
  float eradius = length(ep.xy);
  float emradius = eradius;
  float eangle = atan(ep.y, ep.x);
  float emangle = eangle;

  mod1(emradius, 0.1);
  mod1(emangle, TAU/60.0);

  vec3 elinec = vec3(1.0)*1.25;

  float efadeout = 1.0 - smoothstep(0.0, 0.9, eradius);

  scol = vec3(0.0);
  scol += 8.0*spaceship_sunCol1*pow(clamp(er, 0.0, 1.0), 8.0);
  scol += spaceship_sunCol1*pow(clamp(er, 0.0, 1.0), 1.0);
  scol += spaceship_sunCol2*efadeout*efadeout;

  vec3 ecol = vec3(0.0);
  ecol += scol;
  ecol += elinec*smoothstep(0.01, 0.0, abs(emradius))*efadeout;
  ecol += elinec*smoothstep(0.015, 0.0, abs(emangle))*efadeout;

  return vec4(ecol, eradius < 1.0);
}

float spaceship_fbm(vec2 p, int mx) {
  const float aa = 0.45;
  const float pp = 2.08;
  const float rr = 1.0;

  float a = 1.0;
  float s = 0.0;
  float d = 0.0;

  for (int i = 0; i < mx; ++i) {
    s += a*vnoise(p);
    d += abs(a);
    a *= aa;
    p *= pp;
    rot(p, rr);
  }

  return 1.0*s/d;
}

vec3 spaceship_normal(vec2 p, int mx) {
  vec2 eps = -vec2(0.0001, 0.0);

  vec3 nor;

  nor.x = spaceship_fbm(p + eps.xy, mx) - spaceship_fbm(p - eps.xy, mx);
  nor.y = 2.0*eps.x;
  nor.z = spaceship_fbm(p + eps.yx, mx) - spaceship_fbm(p - eps.yx, mx);

  return normalize(nor);
}

vec3 spaceship_islands(vec3 col, vec3 p, vec3 n, vec2 sp, float level) {
  level += 0.7;
  float beachLevel = level + 0.025;

  vec3 sunDir = normalize(spaceship_sunPos - p);

  sp *= 2.0;
  float hih = spaceship_fbm(sp, 6);
  float loh = spaceship_fbm(sp+vec2(0.075-0.075*sp.x/spaceship_innerLength, 0.0), 3);
  vec3 hn = spaceship_normal(sp, 6);

  vec3 nn = normalize(hn + n);

  const vec3 sandCol = vec3(1.0, 0.95, 0.9);

  float fdiff = pow(max(dot(sunDir, nn), 0.0), 0.5);

  vec4 treePattern = voronoi(sp*40.0);
  vec3 islandCol  = mix(vec3(0.5, 0.75, 0.0), vec3(0.1, 0.45, 0.0), treePattern.y*fdiff*2.0);
  islandCol *= 1.0 - treePattern.x * 0.75;

  col = mix(0.0, 1.0, hih < level)*mix(sandCol, col , 1.0 - exp(8.0*vec3(2.0, 1.0, 1.0)*(hih-level)));
  col = mix(col, sandCol, vec3((beachLevel >  hih) && (hih > level)));
  col = mix(col, islandCol, vec3(hih > beachLevel));
  // Really REALLY fake lighting+shadows
  const float hh = 0.125;
  vec3 scol = vec3(1.0)*(smoothstep(level, level+hh, hih) - smoothstep(level, level+hh, loh));
  col = col+scol*0.5;

  return col;
}

vec3 spaceship_clouds(vec3 col, vec3 ro, vec3 rd, vec3 p, vec3 n, vec2 sp, float level) {
  level += 0.5;

  vec3 ref = reflect(rd, n);

  vec3 sunDir = normalize(spaceship_sunPos - p);
  float sunL2 = l2(spaceship_sunPos - p);
  float sunDiff = max(dot(sunDir, n), 0.0);
  float sunIll = 20.0/(10.0+sunL2);
  float spe1 = 0.5*pow(max(dot(sunDir, ref), 0.0), 10.0);
  float spe2 = pow(max(dot(sunDir, ref), 0.0), 100.0);

  sp *= 2.0;
  sp += 100.0;
  float hih = max(spaceship_fbm(sp, 6) - level, 0.0);
  float loh = max(spaceship_fbm(sp, 3) - level, 0.0);;

  // More fake stuff
  float m = clamp(1.0- exp(-15.0*(hih-0.5*loh)), 0.0, 1.0);

  col = mix(col, vec3(1.25)*spaceship_sunCol1*(sunIll + spe1 + spe2), m*m*m);

  return col;
}

vec3 spaceship_cloudShadows(vec3 col, vec3 p, float level) {
  level += 0.5;

  vec3 sunDir = normalize(spaceship_sunPos - p);

  vec2 ci = rayCylinder(p, sunDir, spaceship_start, vec4(0.0, 0.0, 1.0, 0.8));

  vec3 pp = p + ci.x*sunDir;
  vec2 pp2 = cylinderCoord(pp);

  pp2 *= 2.0;
  pp2 += 100.0;
  float loh = max(spaceship_fbm(pp2, 3) - level, 0.0);

  return col*mix(0.3, 1.0, exp(-3.0
  *loh));
}

vec3 spaceship_sea(vec3 ro, vec3 rd, vec3 n, vec3 p, vec2 sp) {

  vec3 ref = reflect(rd, n);
  ref = normalize(ref + 0.025*psin(mix(110.0, 220.0, psin(2.0*p.z+0.2*p.x))*p.z));

  vec3 sunDir = normalize(spaceship_sunPos - p);
  float sunL2 = l2(spaceship_sunPos - p);
  float sunDiff = max(dot(sunDir, n), 0.0);
  float sunIll = 20.0/(10.0+sunL2);
  float spe2 = pow(max(dot(sunDir, ref), 0.0), 100.0);

  vec3 seaCol = vec3(0.0);
  seaCol += 1.0*spaceship_seaCol2*pow(1.0-max(dot(n, ref), 0.0), 0.45);
  seaCol += spaceship_seaCol1*0.5*sunIll;
  seaCol += spaceship_seaCol1*spaceship_sunCol1*sunDiff*sunIll;
  seaCol += spaceship_sunCol1*spe2;

  return seaCol;
}

vec3 spaceship_shipInterior(vec3 ro, vec3 rd, float input0, float input1) {
  ro += rd*0.05;

  float fd = (0.0 - ro.z)/rd.z;
  vec2 di = raySphere(ro, rd, vec4(spaceship_start, 1.0));
  vec2 ci = rayCylinder(ro, rd, spaceship_start, vec4(0.0, 0.0, 1.0, 0.8));
  vec2 gi = rayCylinder(ro, rd, spaceship_start, vec4(0.0, 0.0, 1.0, 0.9));

  vec3 dp = ro + rd*di.y;
  vec3 dn = -normalize(dp  -spaceship_start);
  vec3 drefr = refract(dp, dn, 1.0/spaceship_refractRatio);
  vec3 dcol = 0.9*spaceship_domeColor(dp, drefr, input0, input1);

  vec3 gp = ro + rd*gi.y;
  vec3 gpy = ro + rd*gi.x;
  vec3 gn = -normalize(vec3(gp.xy-spaceship_start.xy, 0.0));
  vec2 gp2 = cylinderCoord(gp);

  vec3 cp = ro + rd*ci.y;
  vec3 cn = -normalize(vec3(cp.xy-spaceship_start.xy, 0.0));

  vec3 fpcol = vec3(0.0);

  vec3 scol;
  vec4 bpcol = spaceship_backplane(ro, rd, scol);
  vec3 bpn = vec3(0.0, 0.0, 1.0);
  float bpdiff = max(dot(rd, bpn), 0.0);

  vec3 col = vec3(0.0);

  col = mix(col, fpcol, vec3(fd > gi.y));
  col = mix(col, dcol, vec3(dp.z < 0.0));
  col = mix(col, bpcol.xyz, bpcol.w);

  if (gp.z > 0.0 && gpy.z < 0.0 && gp.z < spaceship_innerLength) {
    float level = 0.0;
    level += 1.0-smoothstep(0.0, 0.1*spaceship_innerLength, gp2.x);
    level += 1.0-smoothstep(0.0, 0.1*spaceship_innerLength, spaceship_innerLength-gp2.x);

    /*
    // Too fix discontinuity. Alternative approach, place the camera correctly ;)
    level += 1.0-smoothstep(-PI, -PI+0.5, gp2.y);
    level += 1.0-smoothstep(PI, PI-0.5, gp2.y);
    */

    level *= 0.125;
    vec3 gcol = spaceship_sea(ro, rd, gn, gp, gp2);
    gcol = spaceship_islands(gcol, gp, gn, gp2, level);
    gcol = spaceship_cloudShadows(gcol, gp, level);
    gcol = spaceship_clouds(gcol, ro, rd, cp, cn, cylinderCoord(cp), level);
    col = gcol;
  }

  float id = max(gi.y-max(gi.x, 0.0), 0.0);
  col = mix(col, spaceship_sunCol1, 1.0-exp(-0.05*id*id));
  col = mix(col, 0.75*scol + 1.25*spaceship_sunCol1, pow(bpdiff, 35.0));

  return col;
}

float spaceship_theShip(float ltime, vec3 p, out float nx, out float ny, out int m) {
  const float rep = 5.0;
  const float tradius = 1.2;
  const float sstep = TAU*1.125/rep;
  const float sradius = 0.45*TAU*1.125/rep;
  rot(p.xy, ltime*TAU/60.0);
  float dcapsule = capsule(p, spaceship_outerLength, 1.0);
  dcapsule = pmin(dcapsule, softBox(p, 0.75), 0.25);
  float dglobe = max(dcapsule, p.z);

  vec3 pc = p;
  pc.z -= 0.5*sstep;
  float n = mod1(pc.z, sstep);
  float dtorus = torus(pc.xzy, vec2(tradius*1.55, 0.025));
  float nm = modPolar(pc.xy, rep);
  float dspoke = cylinder(pc, vec3(tradius*1.55, 0.0, 0.025));
  dtorus = min(dtorus, dspoke);
  dtorus = max(dtorus, -p.z + sstep*0.5-0.025);
  dtorus = max(dtorus, p.z-sstep*5.0 + sstep*0.5-0.025);
  float dbattery = sphere(pc - vec3(tradius, 0.0, 0.0), sradius);
  float dbox = softBox(pc - vec3(tradius, 0.0, 0.0), sradius*0.9);
  dbox = roundDiff(dbox, dbattery, 0.125);
  dbattery = min(dbattery, dbox);
  dbattery = max(dbattery, -p.z + sstep*0.05);
  dbattery = max(dbattery, p.z-sstep*5.0);
  float dengine1 = sphere((p-vec3(0.0, 0.0, spaceship_outerLength+1.0)), 0.9);
  float dengine2 = sphere((p-vec3(0.0, 0.0, spaceship_outerLength+2.0)), 0.9);
  float dengine3 = sphere((p-vec3(0.0, 0.0, spaceship_outerLength+1.0)), 0.25);
  float dengine = dengine1;
  dengine = max(dengine, -dengine2);
  dengine = min(dengine, dengine3);
  vec3 pe = p;
  pe -= vec3(0.0, 0.0, spaceship_outerLength+1.8);
  mod1(pe.x, 0.5);
  mod1(pe.y, 0.5);
  float d = dcapsule;
  d = min(d, dengine);
  d = chamfer(d, dbattery, 0.035);
  d = min(d, dtorus);


  m = 1;

  if (d == dglobe) m = 3;
  if (d == dbattery) m = 4;
  if (d == dtorus) m = 1;
  if (d == dbox) m = 2;
  if (d == dengine1) m = 2;
  if (d == -dengine2) m = 5;
  if (d == dengine3) m = 5;

  nx = n;
  ny = nm;

  return d;
}

float spaceship_map(float ltime, vec3 p, out float nx, out float ny, out int m) {
  return spaceship_theShip(ltime, p, nx, ny, m);
}


float spaceship_rayMarch(float ltime, vec3 ro, vec3 rd, out float nx, out float ny, out int mat, out int iter) {
  float t = 0.0;
  float d;
  int i;
  for (i = 0; i < SPACESHIP_MAX_RAY_MARCHES; i++)
  {
    d = spaceship_map(ltime, ro + rd*t, nx, ny, mat);
    if (d < SPACESHIP_TOLERANCE || t > SPACESHIP_MAX_RAY_LENGTH) break;
    t += d; // 0.9
  }
  iter = i;

  if (abs(d) > 10.0*SPACESHIP_TOLERANCE) return SPACESHIP_MAX_RAY_LENGTH;

  return t;
}

vec3 spaceship_normal(float ltime, vec3 pos) {
  vec3  eps = vec3(SPACESHIP_NORM_OFF,0.0,0.0);
  vec3 nor;
  float nx;
  float ny;
  int mat;
  nor.x = spaceship_map(ltime, pos+eps.xyy, nx, ny, mat) - spaceship_map(ltime, pos-eps.xyy, nx, ny, mat);
  nor.y = spaceship_map(ltime, pos+eps.yxy, nx, ny, mat) - spaceship_map(ltime, pos-eps.yxy, nx, ny, mat);
  nor.z = spaceship_map(ltime, pos+eps.yyx, nx, ny, mat) - spaceship_map(ltime, pos-eps.yyx, nx, ny, mat);
  return normalize(nor);
}

vec3 spaceship_innerColor(float ltime, vec3 ro, vec3 rd, vec3 nor, float nx, float ny) {
  vec2 f = hash2(137.0*vec2(nx, ny)+27.0);
  vec3 refr = refract(rd, nor, 3.0);
  float dim = smoothstep(0.6, 0.7, f.x);
  dim *= mix(0.5, 1.0, psin(2.0*ltime+f.y*TAU));
  float s1 = mix(0.3, 2.0, dim);
  float s2 = mix(1.0, 1.25, dim);
  float m = max(dot(nor, -refr), 0.0);
  return 1.5*s1*pow(vec3(1.2, 1.1, s2)*m, 1.25*vec3(2.5, 2.5, 5.5));
}

vec3 engineColor(vec3 ro, vec3 rd, vec3 nor) {
  float eradius = length(ro.xy);
  float emradius = eradius;
  float eangle = atan(ro.y, ro.x);
  float emangle = eangle;

  mod1(emradius, 0.2);
  mod1(emangle, TAU/20.0);

  vec3 elinec = vec3(1.0)*1.25;

  float efadeout = 1.0 - smoothstep(0.0, 0.75, eradius);
  float ifadeout = smoothstep(0.2, 0.225, eradius);

  vec3 refr = refract(rd, nor, 1.25);
  float m = max(dot(nor, -refr), 0.0);


  vec3 scol = vec3(0.0);
  scol += 4.0*spaceship_engineCol1*pow(m, 4.0);
  scol += spaceship_engineCol2*2.0;
  scol *= 1.0- ifadeout;

  vec3 ecol = vec3(0.0);
  ecol += elinec*smoothstep(0.02, 0.0, abs(emradius))*efadeout;
  ecol += elinec*smoothstep(0.05, 0.0, abs(emangle))*efadeout;
  ecol += spaceship_engineCol2*2.0*efadeout*efadeout;
  ecol *= ifadeout;

  return ecol + scol;
}

vec3 spaceship_render(float ltime, float input0, float input1, vec3 ro, vec3 rd) {
  // background color
  vec3 color  = vec3(0.5, 0.8, 1.0);

  int mat = 0;
  int iter = 0;
  float nx;
  float ny;
  float t = spaceship_rayMarch(ltime, ro, rd, nx, ny, mat, iter);

//  vec3 icol = 1.0*vec3(1.0, 0.0, 0.9)*smoothstep(0.5, 1.0, float(iter)/MAX_RAY_MARCHES);
  const  vec3 icol = vec3(0.0);

  vec3 pos = ro + t*rd;
  vec3 nor = spaceship_normal(ltime, pos);

  float ndif = 1.0;
  float nref = 0.8;

  vec3 ref  = reflect(rd, nor);
  vec3 rcol = spaceship_refColor(pos, ref, input0, input1);
  vec3 refr = refract(rd, nor, spaceship_refractRatio);

  if (t < SPACESHIP_MAX_RAY_LENGTH) {
    // Ray intersected object

    switch(mat) {
    case 0:
      color = mix(vec3(1.0), nor*nor, 0.5);
      ndif = 0.75;
      nref = 0.7;
      break;
    case 1:
      color = vec3(0.9) + abs(nor.zxy)*0.1;
      ndif = 0.75;
      nref = 0.7;
      break;
    case 2:
      color = vec3(0.25) + abs(nor.zxy)*0.05;
      ndif = 0.5;
      nref = 0.9;
      break;
    case 3:
      vec3 sicol = spaceship_shipInterior(pos, refr, input0, input1);
      color = mix(sicol, rcol, vec3(refr == vec3(0.0)));
      ndif = 0.5;
      nref = 0.9;
      break;
    case 4:
      color = spaceship_innerColor(ltime, pos, rd, nor, nx, ny);
      ndif = 0.75;
      nref = 0.9;
      break;
    case 5:
      color = engineColor(pos, rd, nor);
      ndif = 0.5;
      nref = 0.75;
      break;
    default:
      color = nor*nor;
      break;
    }

  }
  else {
    // Ray intersected sky
    return spaceship_skyColor(ro, rd, input0, input1) + icol;
  }

  vec3 ld0  = vec3(0.0, 1.0, 0.0);

  vec3 lv1  = sunDirection;
  float ll1 = length(lv1);
  vec3 ld1  = lv1 / ll1;

  vec3 lv2  = smallSunDirection;
  float ll2 = length(lv2);
  vec3 ld2  = lv2 / ll2;

  int rmat = 0;
  int riter = 0;
  float st  = spaceship_rayMarch(ltime, pos + ref*10.0*SPACESHIP_TOLERANCE, ref, nx ,ny, rmat, riter);
  float sha2 = st < SPACESHIP_MAX_RAY_LENGTH ? 0.0 : 1.0;

  float dif0 = pow(max(dot(nor,ld0),0.0), ndif);
  float dif1 = pow(max(dot(nor,ld1),0.0), ndif);
  float dif2 = pow(max(dot(nor,ld2),0.0), ndif);

  vec3 col0 = mix(vec3(1.0), dif0*vec3(1.0), 0.8);
  vec3 col1 = mix(vec3(1.0), dif1*spaceship_sunCol1, 0.8);
  vec3 col2 = mix(vec3(1.0), dif2*spaceship_sunCol2, 0.8);

  vec3 col = mix(rcol*sha2, color*(col0 + col1 + col2)/2.0, nref);

  return col + icol;
}

vec3 spaceship_fragment(float ltime, float input0, float input1, vec3 ro, vec3 uu, vec3 vv, vec3 ww, vec2 p) {
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.0*ww);
  return spaceship_render(ltime, input0, input1, ro, rd);
}


vec3 spaceship_effect(int minor, float input0, float input1, float ltime, vec2 p, vec2 q) {

  vec3 ro  =vec3(1.0, 0.0, -3.0);
  vec3 la = vec3(0.0, 0.0, 0.0);
  vec3 up = vec3(0.0, 1.0, 0.0);

  switch(minor) {
  case MINOR_FROM_BEHIND:
    ro = 3.0*vec3(0.5-ltime/10., 1.0+ltime/5.0, 15.0-ltime);
    break;
  case MINOR_CYLINDER_SEA:
    ro = vec3(-7.5+ltime, 0.5, -1.5-ltime/10.0);
    break;
  case MINOR_FROM_FRONT:
    ro = -3.0*vec3(-0.5+ltime/10., 1.0-ltime/5.0, 10.0-ltime);
    break;
  default:
    break;
  }


  vec3 ww = normalize(la - ro);
  vec3 uu = normalize(cross(up, ww ));
  vec3 vv = normalize(cross(ww,uu));

  float s = 2.0/RESOLUTION.y;

  vec2 o1 = vec2(1.0/8.0, 3.0/8.0)*s;
  vec2 o2 = vec2(-3.0/8.0, 1.0/8.0)*s;

  vec3 col = vec3(0.0);

  // https://blog.demofox.org/2015/04/23/4-rook-antialiasing-rgss/
  col += spaceship_fragment(ltime, input0, input1, ro, uu, vv, ww, p+o1);

#ifdef AA
  // Adaptive AA? Is that a good idea?
  vec3 dcolx = dFdx(col);
  vec3 dcoly = dFdy(col);
  vec3 dcol = sqrt(dcolx*dcolx+dcoly*dcoly)/(col+1.0/256);
//  vec3 dcol = sqrt(dcolx*dcolx+dcoly*dcoly);

  float de = max(dcol.x, max(dcol.y, dcol.z));
  if (de > 0.1) {
    col += spaceship_fragment(ltime, ro, uu, vv, ww, p-o1);
    col += spaceship_fragment(ltime, ro, uu, vv, ww, p+o2);
    col += spaceship_fragment(ltime, ro, uu, vv, ww, p-o2);
    col *=0.25;
//    col = vec3(1.0, 0.0, 0.0);
  }
#endif

  return col;
}

#endif

// -----------------------------==> SPACESHIP <==------------------------------

// -------------------------------==> MAIN <==---------------------------------

vec3 mainImage(vec2 p, vec2 q) {
  p.x *= RESOLUTION.x/RESOLUTION.y;

  const float effectNo = 0.0;
  const float totalTime = float(effects.length())*DURATION + (DURATION1-DURATION);
  float dtime = mod(max(TIME, 0.0), totalTime)-(DURATION1 - DURATION);

  float timeInEffect = mod(dtime, DURATION);
  int effectIndex = int(effectNo + mod(dtime/DURATION, float(effects.length())));

  if (dtime < DURATION) {
    // Special handling for first effect
    timeInEffect = dtime+DURATION1 - DURATION;
    effectIndex = 0;
  }

  Effect effect = effects[effectIndex];
  Effect nextEffect = effects[int(((effectIndex + 1)%effects.length()))];
  float ltime = timeInEffect + effect.seq*DURATION;

  vec3 col = vec3(0.5);


  switch(effect.major) {
#ifdef ENABLE_NOEFFECT
  case MAJOR_NOEFFECT:
    col = noeffect_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_IMPULSE
  case MAJOR_IMPULSE:
    col = impulse_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_ORRERY
  case MAJOR_ORRERY:
    col = orrery_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_WATERWORLD
  case MAJOR_WATERWORLD:
    col = waterworld_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_BARRENMOON
  case MAJOR_BARRENMOON:
    col = barrenmoon_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_GALAXY
  case MAJOR_GALAXY:
    col = galaxy_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
#ifdef ENABLE_SPACESHIP
  case MAJOR_SPACESHIP:
    col = spaceship_effect(effect.minor, effect.input0, effect.input1, ltime, p, q);
    break;
#endif
  default:
    col = vec3(0.5, 0.0, 0.0);
    break;
  }

  col = clamp(col, 0.0, 1.0);

  float fadeIn  = smoothstep(0.0, FADEIN, timeInEffect);
  float fadeOut = smoothstep(DURATION - FADEOUT, DURATION, timeInEffect);
  float tfadeout = smoothstep(DURATIONT - 2.0*DURATION, DURATIONT, TIME);

  if (effect.fade && effect.seq == 0.0) {
    col = mix(vec3(0.0), col, fadeIn*fadeIn);
  }

  if (effect.fade && nextEffect.seq == 0.0){
    col = mix(col, vec3(0.0), fadeOut*fadeOut);
  }

  col = mix(col, vec3(0.0), tfadeout*tfadeout);

  return col;
}

// -------------------------------==> MAIN <==---------------------------------
