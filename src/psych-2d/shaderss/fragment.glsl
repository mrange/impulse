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

void mainImage(out vec4, in vec2, in vec2);
void main(void)
{
#if defined(SCREEN_LOADER)
  mainImage(fragColor, p, q);
#else
  mainImage(fragColor, -1.0 + 2.0*inData.v_texcoord, inData.v_texcoord);
#endif
}

// License CC0: mrange
//  Timed (poorly) to the excellent track Sprung by Astroboy, CC-nc-nd

// ------------------------------==> COMMON <==--------------------------------

#define PI              3.141592654
#define TAU             (2.0*PI)
#define TIME            time
#define RESOLUTION      resolution

#define SCA(a)          vec2(sin(a), cos(a))
#define LESS(a,b,c)     mix(a,b,step(0.,c))
#define SABS(x,k)       LESS((.5/k)*x*x+k*.5,abs(x),abs(x)-k)

#define MINOR_NONE       0

#define MAJOR_TUNNEL     0

#define MINOR_STARFIELD  0
#define MINOR_POLYGON    1
#define MINOR_STARS      2
#define MINOR_CIRCLES    3
#define MINOR_ICIRCLES   4

#define MAJOR_IMPULSE    1
#define MINOR_80S        0
#define MINOR_PULSAR     1

#define MAJOR_DRAGON     2
#define MINOR_FADEIN     1

#define MAJOR_ACID       3

#define MAJOR_SMEAR      4

#define MAJOR_GLOWBALL   5

#define MAJOR_DREAMS     6

#define MAJOR_FORT       7

#define MAJOR_JUPYTER    8
#define MINOR_PLANET     0
#define MINOR_FLAT       1
#define MINOR_MIRROR     2
#define MINOR_KALEIDO    3

struct Effect {
  int      major  ;
  int      minor  ;
  float    seq    ;
  float    input0 ;
  float    input1 ;
};

const float effectDuration  = 6.75;
const float fadeTime        = 1.0;
const float songLength      = 488.0;

// Uncomment to speed up experimentation
//#define EXPERIMENTING

#ifdef EXPERIMENTING
#define START_DELAY   0.0
#define ENABLE_DRAGON
#define ENABLE_DREAMS
const Effect effects[] = Effect[](
    Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, 0.0       , effectDuration/8.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 1.0, 0.0       , effectDuration/8.0)
  );
#else
#define START_DELAY   3.24
#define ENABLE_TUNNEL
#define ENABLE_IMPULSE
#define ENABLE_DRAGON
#define ENABLE_ACID
#define ENABLE_SMEAR
#define ENABLE_GLOWBALL
#define ENABLE_DREAMS
#define ENABLE_FORT
#define ENABLE_JUPYTER

const Effect effects[] = Effect[](
    Effect(MAJOR_DRAGON  , MINOR_FADEIN    , 0.0, 1.4          , 5.5)
  , Effect(MAJOR_DRAGON  , MINOR_FADEIN    , 1.0, 1.4          , 5.5)
  , Effect(MAJOR_IMPULSE , MINOR_80S       , 0.0, 0.0          , 0.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, 1.0          , 5.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 1.0, 1.0          , 5.0)
  , Effect(MAJOR_TUNNEL  , MINOR_STARFIELD , 0.0, pow(0.5, 4.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_CIRCLES   , 0.0, pow(0.5, 2.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_CIRCLES   , 0.0, pow(0.5, 5.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_CIRCLES   , 0.0, pow(0.5, 8.0), 0.0)
  , Effect(MAJOR_IMPULSE , MINOR_PULSAR    , 0.0, PI/10.0      , 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 0.0, pow(0.5, 5.0), 3.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 1.0, pow(0.5, 5.0), 3.0)
  , Effect(MAJOR_TUNNEL  , MINOR_STARS     , 0.0, pow(0.5, 5.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 0.0, pow(0.5, 5.0), 5.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 1.0, pow(0.5, 5.0), 5.0)
  , Effect(MAJOR_JUPYTER , MINOR_FLAT      , 0.0, 45.0         , 0.0)
  , Effect(MAJOR_JUPYTER , MINOR_FLAT      , 1.0, 45.0         , 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 0.0, pow(0.5, 2.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 0.0, pow(0.5, 4.0), 0.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, -1.0         , 5.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 1.0, -1.0         , 5.0)
  , Effect(MAJOR_ACID    , MINOR_NONE      , 0.0, 1.0          , 0.1)
  , Effect(MAJOR_ACID    , MINOR_NONE      , 1.0, 1.0          , 0.1)
  , Effect(MAJOR_SMEAR   , MINOR_NONE      , 0.0, 140.0        , 0.0)
  , Effect(MAJOR_SMEAR   , MINOR_NONE      , 1.0, 140.0        , 0.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, 1.4          , 5.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 1.0, 1.4          , 5.0)
  , Effect(MAJOR_TUNNEL  , MINOR_STARFIELD , 0.0, pow(0.5, 5.0), 0.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, 0.0          , effectDuration/8.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 0.0, pow(0.5, 4.0), 2.0)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 1.0, pow(0.5, 4.0), 2.0)
  , Effect(MAJOR_JUPYTER , MINOR_MIRROR    , 0.0, 47.0         , 0.0)
  , Effect(MAJOR_JUPYTER , MINOR_MIRROR    , 1.0, 47.0         , 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 0.0, pow(0.5, 3.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 1.0, pow(0.5, 3.0), 0.0)
  , Effect(MAJOR_FORT    , MINOR_NONE      , 0.0, 1.0          , 0.2)
  , Effect(MAJOR_FORT    , MINOR_NONE      , 0.0, 2.0          , 0.5)
  , Effect(MAJOR_FORT    , MINOR_NONE      , 0.0, 3.0          , 0.8)
  , Effect(MAJOR_IMPULSE , MINOR_PULSAR    , 0.0, PI/10.0      , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 0.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 1.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 2.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 3.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 4.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 5.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 6.0, -35.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 7.0, -35.0        , 0.0)
  , Effect(MAJOR_GLOWBALL, MINOR_NONE      , 0.0, 1.0          , 0.5)
  , Effect(MAJOR_GLOWBALL, MINOR_NONE      , 0.0, 11.0         , 0.5)
  , Effect(MAJOR_GLOWBALL, MINOR_NONE      , 0.0, 317.0        , 0.5)
  , Effect(MAJOR_TUNNEL  , MINOR_POLYGON   , 0.0, pow(0.5, 5.0), 5.0)
  , Effect(MAJOR_JUPYTER , MINOR_KALEIDO   , 0.0, 70.0         , 0.0)
  , Effect(MAJOR_JUPYTER , MINOR_KALEIDO   , 1.0, 70.0         , 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 0.0, pow(0.5, 2.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 1.0, pow(0.5, 2.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 0.0, pow(0.5, 5.0), 0.0)
  , Effect(MAJOR_TUNNEL  , MINOR_ICIRCLES  , 1.0, pow(0.5, 5.0), 0.0)
  , Effect(MAJOR_ACID    , MINOR_NONE      , 0.0, 3.0          , 0.5)
  , Effect(MAJOR_ACID    , MINOR_NONE      , 1.0, 3.0          , 0.5)
  , Effect(MAJOR_JUPYTER , MINOR_KALEIDO   , 0.0, 80.0         , 0.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 0.0, 1.0          , 5.0)
  , Effect(MAJOR_DRAGON  , MINOR_NONE      , 1.0, 1.0          , 5.0)
  , Effect(MAJOR_FORT    , MINOR_NONE      , 0.0, 3.0          , 0.1)
  , Effect(MAJOR_JUPYTER , MINOR_NONE      , 0.0, 0.0          , 0.0)
  , Effect(MAJOR_FORT    , MINOR_NONE      , 0.0, 3.0          , 1.0)
  , Effect(MAJOR_JUPYTER , MINOR_MIRROR    , 0.0, 130.0        , 0.0)
  , Effect(MAJOR_JUPYTER , MINOR_MIRROR    , 1.0, 130.0        , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 0.0, 24.0         , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 1.0, 24.0         , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 2.0, 24.0         , 0.0)
  , Effect(MAJOR_DREAMS  , MINOR_NONE      , 3.0, 24.0         , 0.0)
  , Effect(MAJOR_IMPULSE , MINOR_80S       , 0.0, 0.0          , 0.0)
  );

#endif
const vec2 sca0 = SCA(0.0);

const float startDelay      = START_DELAY;

highp float rand(vec2 co) {
  highp float a = 12.9898;
  highp float b = 78.233;
  highp float c = 43758.5453;
  highp float dt= dot(co.xy ,vec2(a,b));
  highp float sn= mod(dt, 3.14);
  return fract(sin(sn) * c);
}

vec2 hash(vec2 p) {
  p = vec2(dot (p, vec2 (127.1, 311.7)), dot (p, vec2 (269.5, 183.3)));
  return -1. + 2.*fract (sin (p)*43758.5453123);
}

float mod1(inout float p, float size) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p + halfsize, size) - halfsize;
  return c;
}

float modMirror1(inout float p, float size) {
    float halfsize = size*0.5;
    float c = floor((p + halfsize)/size);
    p = mod(p + halfsize,size) - halfsize;
    p *= mod(c, 2.0)*2.0 - 1.0;
    return c;
}

vec2 mod2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size*0.5)/size);
  p = mod(p + size*0.5,size) - size*0.5;
  return c;
}

float pmin(float a, float b, float k) {
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

float pdiff(float d1, float d2, float k) {
  float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
  return mix( d2, -d1, h ) + k*h*(1.0-h);
}

void rot(inout vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  p = vec2(c*p.x + s*p.y, -s*p.x + c*p.y);
}

vec2 toPolar(vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}

vec2 toRect(vec2 p) {
  return vec2(p.x*cos(p.y), p.x*sin(p.y));
}

vec2 toSmith(vec2 p)  {
  // z = (p + 1)/(-p + 1)
  // (x,y) = ((1+x)*(1-x)-y*y,2y)/((1-x)*(1-x) + y*y)
  float d = (1.0 - p.x)*(1.0 - p.x) + p.y*p.y;
  float x = (1.0 + p.x)*(1.0 - p.x) - p.y*p.y;
  float y = 2.0*p.y;
  return vec2(x,y)/d;
}

vec2 fromSmith(vec2 p)  {
  // z = (p - 1)/(p + 1)
  // (x,y) = ((x+1)*(x-1)+y*y,2y)/((x+1)*(x+1) + y*y)
  float d = (p.x + 1.0)*(p.x + 1.0) + p.y*p.y;
  float x = (p.x + 1.0)*(p.x - 1.0) + p.y*p.y;
  float y = 2.0*p.y;
  return vec2(x,y)/d;
}

float holey(float d, float k) {
  return abs(d) - k;
}

float plane(vec2 p, vec2 n, float m) {
  return dot(p, n) + m;
}

float circle(vec2 p, float r) {
  return length(p) - r;
}

float box(vec2 p, vec2 b, float r) {
  b -= r;
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0) - r;
}

float horseshoe(vec2 p, vec2 c, float r, vec2 w) {
  p.x = abs(p.x);
  float l = length(p);
  p = mat2(-c.x, c.y, c.y, c.x)*p;
  p = vec2((p.y>0.0)?p.x:l*sign(-c.x),(p.x>0.0)?p.y:l);
  p = vec2(p.x,abs(p.y-r))-w;
  return length(max(p,0.0)) + min(0.0,max(p.x,p.y));
}

float star5(vec2 p, float r, float rf) {
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

float roundedX(vec2 p, float w, float r) {
  p = abs(p);
  return length(p-min(p.x+p.y,w)*0.5) - r;
}

float letteri(vec2 p) {
  p.y -= 0.25;
  return box(p, vec2(0.125, 0.75), 0.0);
}


float letterm(vec2 p) {
  p.y = -p.y;
  float l = horseshoe(p - vec2(+0.5, 0.0), sca0, 0.5, vec2(0.5, 0.1));
  float r = horseshoe(p - vec2(-0.5, 0.0), sca0, 0.5, vec2(0.5, 0.1));
  return min(l, r);
}

float letterp(vec2 p) {
  float b = box(p - vec2(-0.45, -0.25), vec2(0.1, 0.75), 0.0);
  float c = max(circle(p, 0.5), -circle(p, 0.3));
  return min(b, c);
}

float letteru(vec2 p) {
  return horseshoe(p - vec2(0.0, 0.125), sca0, 0.5, vec2(0.375, 0.1));
}

float letterl(vec2 p) {
  return box(p, vec2(0.125, 0.5), 0.0);
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
  return min(box(p, vec2(0.4, 0.1), 0.0), max(circle(p, 0.5), -circle(p, 0.3)));
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


float spokes(vec2 p, float a) {
  vec2 pp = toPolar(p);
  pp.y += a;
  mod1(pp.y, TAU/10.0);
  pp.y += PI/2.0;
  p = toRect(pp);
  float ds = box(p, vec2(0.075, 0.5)*6.0, 0.04*6.0);
  return ds;
}

float cog(vec2 p, float a) {
  float c = circle(p, 6.0*0.375);
  float s = spokes(p, a);
  return min(c, s);
}

float cogImpulse(vec2 p, float time) {
  float a = time*TAU/60.0;
  float c = cog(p, a);
  float i = impulse(p)-0.025;

  vec2 pp = toPolar(p);
  pp.y += a;
  mod1(pp.y, TAU/5.0);
  vec2 rp = toRect(pp);
  float ic = circle(rp - vec2(6.0*0.22, 0.0), 6.0*0.1);

  c = max(c, -(i-0.15));
//  c = max(c, -ic);

  float d = i;
  d = min(d, c);

  return d;
}

float soft_noise(vec2 p) {
  const float K1 = .366025404;
  const float K2 = .211324865;

  vec2 i = floor (p + (p.x + p.y)*K1);

  vec2 a = p - i + (i.x + i.y)*K2;
  vec2 o = step (a.yx, a.xy);
  vec2 b = a - o + K2;
  vec2 c = a - 1. + 2.*K2;

  vec3 h = max (.5 - vec3 (dot (a, a), dot (b, b), dot (c, c) ), .0);

  vec3 n = h*h*h*h*vec3 (dot (a, hash (i + .0)),dot (b, hash (i + o)), dot (c, hash (i + 1.)));

  return dot (n, vec3 (70.));
}

float soft_fbm(vec2 pos, float tm) {
  vec2 offset = vec2(cos(tm), sin(tm*sqrt(0.5)));
  float aggr = 0.0;

  aggr += soft_noise(pos);
  aggr += soft_noise(pos + offset) * 0.5;
  aggr += soft_noise(pos + offset.yx) * 0.25;
  aggr += soft_noise(pos - offset) * 0.125;
  aggr += soft_noise(pos - offset.yx) * 0.0625;

  aggr /= 1.0 + 0.5 + 0.25 + 0.125 + 0.0625;

  return (aggr * 0.5) + 0.5;
}

const mat2 warped_frot = mat2(0.80, 0.60, -0.60, 0.80);

float warped_noise(vec2 p) {
  float a = sin(p.x);
  float b = sin(p.y);
  float c = 0.5 + 0.5*cos(p.x + p.y);
  float d = mix(a, b, c);
  return d;
}

float warped_fbm(vec2 p) {
  float f = 0.0;
  float a = 1.0;
  float s = 0.0;
  float m = 2.0-0.1;
  for (int x = 0; x < 4; ++x) {
    f += a*warped_noise(p); p = warped_frot*p*m;
    m += 0.01;
    s += a;
    a *= 0.45;
  }
  return f/s;
}

float warped_warp(vec2 p, float ttime, float offset, float dist, out vec2 v, out vec2 w) {
  vec2 vx = vec2(0.0, 0.0);
  vec2 vy = vec2(3.2, 1.3);

  vec2 wx = vec2(1.7, 9.2);
  vec2 wy = vec2(8.3, 2.8);

  vec2 off = (1.75 + 0.5*cos(ttime/60.0))*vec2(-5, 5);

  p += dist*mix(vec2(0.0), off, 0.5 + 0.5*tanh(offset));

  rot(vx, ttime/1000.0);
  rot(vy, ttime/900.0);

  rot(wx, ttime/800.0);
  rot(wy, ttime/700.0);

  vec2 vv = vec2(warped_fbm(p + vx), warped_fbm(p + vy));
  vec2 ww = vec2(warped_fbm(p + 3.0*vv + wx), warped_fbm(p + 3.0*vv + wy));

  float f = warped_fbm(p + 2.25*ww);

  v = vv;
  w = ww;

  return f;
}

vec3 warped_normal(vec2 p, float time, float offset, float dist) {
  vec2 v;
  vec2 w;
  vec2 e = vec2(0.0001, 0);

  vec3 n;
  n.x = warped_warp(p + e.xy, time, offset, dist, v, w) - warped_warp(p - e.xy, time, offset, dist, v, w);
  n.y = 2.0*e.x;
  n.z = warped_warp(p + e.yx, time, offset, dist, v, w) - warped_warp(p - e.yx, time, offset, dist, v, w);

  return normalize(n);
}

vec3 postProcess(vec3 col, vec2 q) {
  col=pow(clamp(col,0.0,1.0),vec3(0.75));
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4);  // satuation
  col*=vec3(0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7));  // vigneting
  return col;
}

// ------------------------------==> COMMON <==--------------------------------

// ------------------------------==> TUNNEL <==--------------------------------

#ifdef ENABLE_TUNNEL

const int   tunnel_furthest   = 24;
const int   tunnel_nearest    = -3;

vec2 tunnel_offset(float gtime, float z) {
  z *= 0.09*sqrt(0.5);
  vec2 o = vec2(0.0);
  vec2 r = vec2(2.2);
  o += r*vec2(cos(z), sin((sqrt(0.5))*z + pow(0.5 + 0.5*sin(sqrt(0.25)*z),5.0)));
  return o;
}


vec3 tunnel_stars(int minor, float input0, float input1, float gtime, float ltime, vec2 p, int gi, float smallRadii, float largeRadii) {
  vec2 pp = toPolar(p);
  pp.x = pp.x*(1.0 + 1.0*pow(length(1.0*p), 0.5));
  pp.y += 0.5*float(gi);
  p = toRect(pp);
//  rot(p, 0.5*gi);
  float m  = smallRadii*mix(1.0, 30.0, pow(smoothstep(0.0, fadeTime+1.0, ltime), 0.25));
  float nx = mod1(p.x, m);
  float ny = mod1(p.y, m);
  vec2 n   = vec2(nx, ny);
  float x  = rand(n + vec2(gi));
  float y  = rand(n - sqrt(0.5)*vec2(gi));
  vec2 off = (0.5*m - 2.0*smallRadii)*vec2(x, y);

  p -= off;

  rot(p, 0.5*gtime + TAU*x);

  float d = star5(p, smallRadii*1.0, 0.5);
//  float d = circle(p, smallRadii);

  return vec3(d, 0.75*length(n), 0.0005*float(gi));
}

float tunnel_expander(int gi) {
  return 0.5 - 0.5*cos(0.05*float(gi));
}

vec3 tunnel_poly(int minor, float input0, float input1, float gtime, float ltime, vec2 p, int gi, float smallRadii, float largeRadii) {
  vec2 pp = toPolar(p);
  pp.y += float(gi)*TAU/60.0-0.3*gtime;
  float nny = mod1(pp.y, TAU/input1);
  p = toRect(pp);
  float di = -p.x + largeRadii;

  float nx = mod1(p.x, smallRadii*2.0);
  float ny = mod1(p.y, smallRadii*(2.0 + 40.0*pow(tunnel_expander(gi), 4.0)));

  float xmul = float(int(nx) & 1)*2.0 - 1.0;
  float ymul = float(int(ny) & 1)*2.0 - 1.0;
  rot(p, ymul*xmul*(gtime - 0.05*float(gi))*TAU/5.0);

  float d = star5(p, smallRadii*1.0, 0.5);
  d = max(d, di);

  return vec3(d, (nx-largeRadii/(smallRadii*2.0)), (smallRadii*ny-0.05*smallRadii*float(gi)));
}

vec3 tunnel_circle(int minor, float input0, float input1, float gtime, float ltime, vec2 p, int gi, float smallRadii, float largeRadii) {
  float reps    = float(int(largeRadii*TAU/(2.0*smallRadii))) - 1.0;
  float degree  = TAU/reps;

  float divend  = 2.0*smallRadii + 2.0*pow(tunnel_expander(gi), 5.0);
  float dx      = largeRadii - 0.5*divend;
  vec2 op = p;

  vec2 pp = toPolar(p);

  float ny = pp.y;
  pp.y += float(gi)*TAU/3.0;
//  pp.y +=-0.33*smallRadii*float(gi) + 0.25*sin(0.3*gi)*time;
  pp.x -= dx;
  float nx = pp.x/divend;
  pp.x = mod(pp.x, divend);
  pp.x += dx;
  float nny = mod1(pp.y, degree);
  pp.y += PI/2.0;
  p = toRect(pp);
  p -= vec2(0.0, largeRadii);

  float xmul = float(int(nx) & 1)*2.0 - 1.0;
  float ymul = float(int(nny) & 1)*2.0 - 1.0;
  rot(p, ymul*xmul*(gtime - 0.05*float(gi))*TAU/5.0);

  float d;
  switch(minor) {
  case MINOR_CIRCLES:    d = circle(p, smallRadii*1.0); break;
  case MINOR_ICIRCLES:   d = -circle(p, smallRadii*1.3); break;
  default:               d = star5(p, smallRadii*1.0, 0.35); break;
  }

//  float d = roundedX(p, smallRadii*0.9, 0.3*smallRadii);
//  float d = -circle(p, smallRadii*1.25);
//  float d = circle(p, smallRadii*1.0);
  float id = circle(op, largeRadii - smallRadii);
  d = max(d, -id);

  return vec3(d, nx, ny);
}

vec3 tunnel_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float smallRadii = input0;
  float largeRadii = 1.0 + 1.0*smallRadii;

  vec3 col = vec3(0);

  gtime *= 1.5;

  float smoothPixel = 5.0/RESOLUTION.y;

  const vec3 baseCol = vec3(1.0);
  const float zbase  = 10.0;
  const float zspeed = 13.0;
  const float zdtime = 0.2*10.0/zspeed;

  float gz       = zspeed*gtime;
  vec2  outerOff = tunnel_offset(gtime, gz);
  float fgtime   = mod(gtime, zdtime);

  for (int i = tunnel_furthest; i >= tunnel_nearest; --i) {
    int   gi      = i + int(gtime/zdtime);
    float lz      = zspeed*(zdtime*float(i) - fgtime);
    float zscale  = zbase/(zbase + lz);

    float iz      = gz + lz;
    vec2 innerOff = tunnel_offset(gtime, iz);

    vec2 ip       = p + 0.5*zscale*(-innerOff + outerOff);
    float ld      = length(ip)/zscale;

    vec2 sip = ip/zscale;
    vec3 ddd;

    switch(minor) {
    case MINOR_STARFIELD:  ddd = tunnel_stars(minor, input0, input1, gtime, ltime, sip, gi, smallRadii, largeRadii); break;
    case MINOR_POLYGON:    ddd = tunnel_poly(minor, input0, input1, gtime, ltime, sip, gi, smallRadii, largeRadii); break;
    case MINOR_STARS:
    case MINOR_CIRCLES:
    case MINOR_ICIRCLES:   ddd = tunnel_circle(minor, input0, input1, gtime, ltime, sip, gi, smallRadii, largeRadii); break;
    default:               ddd = vec3(0.0); break;
    }

    ddd *= zscale;

    float d       = ddd.x;
    vec3 scol     = baseCol*vec3(0.6 + 0.4*sin(TAU*ddd.y*0.005 - 0.2*iz), pow(0.6 + 0.4*cos(-2.0*abs(ddd.z)-0.4*iz-0.5*gtime), 1.0), 0.8);

    float diff = exp(-0.0125*lz)*(1.0 - 1.0*tanh(pow(0.4*max(ld - largeRadii, 0.0), 2.0) + 3.0*smallRadii*max(ddd.y, 0.0)));

    vec4 icol = diff*vec4(scol, smoothstep(0.0, -smoothPixel, d));

    icol.w += diff*diff*diff*0.75*clamp(1.0 - 30.0*d, 0.0, 1.0);
    icol.w += tanh(0.025*lz)*0.5*ld*clamp(1.5 - ld, 0.0, 1.0);

    icol.w *= clamp(1.0 - fgtime/zdtime, 1.0 - step(float(i), float(tunnel_nearest)), 1.0);
    icol.w *= clamp(fgtime/zdtime, step(float(i), float(tunnel_furthest-1)), 1.0);


    col = mix(col, icol.xyz, clamp(icol.w, 0.0, 1.0));
  }

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> TUNNEL <==--------------------------------

// ------------------------------==> IMPULSE <==-------------------------------


#ifdef ENABLE_IMPULSE

const vec2 impulse_coff = vec2(-3.6, 1.4);

float impulse_df(float ltime, vec2 p, vec2 coff, float dist) {
  vec2 cp = p - coff;
  float di = impulse(p)*dist;
  float dc = circle(cp, 0.2);
  float d = di;
  d = pmin(d, dc, 0.1);

  return d;
}

vec3 impulse_80S(float gtime, float ltime, float z, vec2 p, vec2 rp) {
  float d  = impulse_df(ltime, rp/z, impulse_coff, 1.0)*z;
  float ds = impulse_df(ltime, (rp - 0.05*vec2(1.0, -1.0))/z, impulse_coff, 1.0)*z;

  float smoothPixel = 5.0/RESOLUTION.y;

  vec3 col = vec3(0.75);

  col = mix(col, vec3(0.5), exp(-200.0*max(ds, 0.0)*ds));

  vec4 icol = vec4(0.0, 0.0, 0.0, 1.0);

  const float sz = 0.0125/2.0;

  icol.xyz += vec3(1.0*max((sz*sz - p.y*p.y)/(sz*sz), 0.0));
  icol.xyz += smoothstep(1.0, 0.0, pow(p.y, 0.5)) * vec3(0.5, 0.75, 1.0);
  icol.xyz += smoothstep(1.0, 0.0, pow(-p.y, 0.5)) * vec3(1.0, 0.75, 0.55);

  icol.xyz = mix(icol.xyz, vec3(0.25), smoothstep(0.0, smoothPixel, d));
  icol.w = smoothstep(0.025, 0.025 + smoothPixel, d);

  col = mix(col, icol.xyz, 1.0 - icol.w);


  return col;
}

vec3 impulse_pulsar(float gtime, float ltime, float z, vec2 p, vec2 rp) {
  float dist = 1.0/(0.5 + pow(abs(tan(-PI/2.0 + 0.75*length((rp - impulse_coff*z))-ltime*PI*2.0/effectDuration)), 1.0));
  float d  = impulse_df(ltime, rp/z, impulse_coff, dist)*z;


  float smoothPixel = 5.0/RESOLUTION.y;

  vec3 col = vec3(0.0);
  const vec3 glow = vec3(1.0, 0.8, 0.8);
  col += vec3(1.0 - pow(smoothstep(0.0, 0.02, -d), 0.5))*1.15*glow;
  vec3 ccol = vec3(1.0 - pow(smoothstep(0.0, 0.04, d), 0.25))*glow;
  col = mix(col, ccol, smoothstep(0.0, 0.005, d));

  return col;
}

vec3 impulse_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  vec3 col = vec3(0.75);

  rot(p, input0);

  float z = 0.425 - ltime*0.0125;
  vec2 pp = toPolar(p);
  float fadeOut = pow(smoothstep(effectDuration - fadeTime, effectDuration, ltime), 2.5);
  float period = mix(TAU*10.0, TAU*20.0, fadeOut);
  pp.x += 0.75*fadeOut*sin(period*p.x)*sin(period*p.y);
  vec2 rp = toRect(pp);

  switch(minor) {
  case MINOR_80S:
    col = impulse_80S(gtime, ltime, z, p, rp); break;
  case MINOR_PULSAR:
    col = impulse_pulsar(gtime, ltime, z, p, rp); break;
  default:
    col = vec3(0.5, 0.5, 0.0);
  }

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> IMPULSE <==-------------------------------

// ------------------------------==> DRAGON <==--------------------------------

#ifdef ENABLE_DRAGON

#define DRAGON_LAYERS      6
#define DRAGON_FBM         3
#define DRAGON_LIGHTNING   3

float dragon_wave(float theta, vec2 p) {
  return (cos(dot(p,vec2(cos(theta),sin(theta)))));
}

float dragon_noise(float distort, vec2 p, float time) {
  float sum = 0.;
  float a = 1.0;
  for(int i = 0; i < DRAGON_LAYERS; ++i)  {
    float theta = float(i)*PI/float(DRAGON_LAYERS);
    sum += dragon_wave(theta, p)*a;
    a*=distort;
  }

  return abs(tanh(sum+1.0+0.75*cos(time)));
}

float dragon_fbm(float distort, vec2 p, float time) {
  float sum = 0.;
  float a = 1.0;
  float f = 1.0;
  for(int i = 0; i < DRAGON_FBM; ++i)  {
    sum += a*dragon_noise(distort, p*f, time);
    a *= 2.0/3.0;
    f *= 2.31;
  }

  return 0.45*(sum);
}

vec3 dragon_lightning(float distort, vec2 pos, float offset, float time) {
  vec3 col = vec3(0.0);
  vec2 f = vec2(0);

  const float w=0.15;

  for (int i = 0; i < DRAGON_LIGHTNING; i++) {
    float time = time + 0.5*float(i);
    float d1 = abs(offset * w / (0.0 + offset - dragon_fbm(distort, (pos + f) * 3.0, time)));
    float d2 = abs(offset * w / (0.0 + offset - dragon_fbm(distort, (pos + f) * 2.0, 0.9 * time + 10.0)));
    col += vec3(clamp(d1, 0.0, 1.0) * vec3(0.1, 0.5, 0.8));
    col += vec3(clamp(d2, 0.0, 1.0) * vec3(0.7, 0.5, 0.3));
  }

  return (col);
}

vec3 dragon_normal(float distort, vec2 p, float time) {
  vec2 v;
  vec2 w;
  vec2 e = vec2(0.00001, 0);

  vec3 n;
  n.x = dragon_fbm(distort, p + e.xy, time) - dragon_fbm(distort, p - e.xy, time);
  n.y = 2.0*e.x;
  n.z = dragon_fbm(distort, p + e.yx, time) - dragon_fbm(distort, p - e.yx, time);

  return normalize(n);
}

vec3 dragon_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float distort = input0;
  float period = input1;
  p += ltime*0.0125;
  p *= 1.0 - ltime*0.0125;
  rot(p, (ltime-effectDuration)*TAU/900.0);
  vec2 pp = 10.0*p;

  ltime += 0.0;

  rot(p, -0.75);
  p *= vec2(1.1/tanh(1.0 + length(p)), 1.0);
  float l = length(p);

  float dd = 0.2 + 0.65*(-0.5 + 1.75*(0.5 + 0.5*cos(3.0*l-ltime*TAU/period)))*tanh(1.0/((pow(l, 4.0) + 2.0)));
  switch(minor) {
  case MINOR_FADEIN:
    dd *= smoothstep(period-3.0, period, ltime-l*2.0);
    break;
  default:
    break;
  }
  vec3 col = vec3(0.0);
  float f = dragon_fbm(distort, pp, ltime*0.1);
  vec3 ld = normalize(vec3(p.x, 0.5, p.y));
  vec3 n = dragon_normal(distort, pp, ltime*0.1);
  float diff = max(dot(ld, n), 0.0);
  col += vec3(0.5, 1.0, 0.8)*pow(diff, 20.0)/(0.5+dot(p, p));
  col += dragon_lightning(distort, pp, dd, ltime);
  col *= pow(vec3(f), vec3(1.5, 5.0, 5.0));
//  col += -0.1+0.3*vec3(0.7, 0.2, 0.4)*vec3(tanh((pow(0.6/f, 10))));

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> DRAGON <==--------------------------------

// -------------------------------==> ACID <==---------------------------------

#ifdef ENABLE_ACID

const float acid_size  = 0.75 ;
const float acid_offc  = 1.05;
const float acid_width = 0.0125;
const int   acid_rep   = 15 ;

#define PHI   (.5*(1.+sqrt(5.)))

const vec3 dodec_plnormal = normalize(vec3(1, 1, -1));
const vec3 dodec_n1 = normalize(vec3(-PHI,PHI-1.0,1.0));
const vec3 dodec_n2 = normalize(vec3(1.0,-PHI,PHI+1.0));
const vec3 dodec_n3 = normalize(vec3(0.0,0.0,-1.0));

float acid_dodec(vec3 z, float ttime) {
  vec3 p = z;
  float t;
  z = abs(z);
  t=dot(z,dodec_n1); if (t>0.0) { z-=2.0*t*dodec_n1; }
  t=dot(z,dodec_n2); if (t>0.0) { z-=2.0*t*dodec_n2; }
  z = abs(z);
  t=dot(z,dodec_n1); if (t>0.0) { z-=2.0*t*dodec_n1; }
  t=dot(z,dodec_n2); if (t>0.0) { z-=2.0*t*dodec_n2; }
  z = abs(z);

  float dmin=dot(z-vec3(acid_size,0.,0.),dodec_plnormal);

  dmin = abs(dmin) - acid_width*7.5*(0.55 + 0.45*sin(10.0*length(p) - 0.5*p.y + ttime/9.0));

  return dmin;
}

float acid_wheel(vec2 p, float ttime, float s) {
  vec2 pp = toPolar(p);
  pp.y += ttime/60.0;
  mod1(pp.y, TAU/10.0);
  pp.y += PI/2.0;
  p = toRect(pp);
  float ds = box(p, s*vec2(0.075, 0.5), s*0.04);

  float dc = circle(p, s*0.375);

  return pmin(ds, dc, s*0.0125);
}

float acid_weird(vec2 p, float soft, float ttime) {
  float d = 100000.0;
  float off = 0.30  + 0.25*(0.5 + 0.5*sin(ttime/11.0));
  for (int i = 0; i < acid_rep; ++i) {
    vec2 ip = p;
    rot(ip, float(i)*TAU/float(acid_rep));
    ip -= vec2(acid_offc*acid_size, 0.0);
    vec2 cp = ip;
    rot(ip, ttime/73.0);
    float dd = acid_dodec(vec3(ip, off*acid_size), ttime);
    float cd = length(cp - vec2(0.25*sin(ttime/13.0), 0.0)) - 0.125*acid_size;
    cd = abs(cd) - acid_width*0.5;
    d = pmin(d, dd, 0.05*soft);
    d = pmin(d, cd, 0.025*soft);
  }
  return d;
}

float acid_df(vec2 p, float soft, float k, float ttime) {
  float dc = acid_wheel(p, ttime, 3.0);
  dc = abs(dc) - 0.2;
  dc = abs(dc) - 0.1;
  dc = abs(dc) - 0.05;
  float dw = acid_weird(p, soft, ttime);
  return pmin(dw, dc, k);
}

vec3 acid_postProcess(vec3 col, vec2 q, vec2 p) {
  col=pow(clamp(col,0.0,1.0),vec3(0.75));
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4);  // satuation
  const float r = 1.5;
  float d = max(r - length(p), 0.0)/r;
  col *= vec3(1.0 - 0.25*exp(-200.0*d*d));
  return col;
}

vec3 acid_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float soft = input0;
  float k = input1;
  ltime -= 0.5;
  float ttime = TAU*ltime;
  float d = acid_df(p, soft, k, ttime);

  float smoothPixel = 5.0/RESOLUTION.y;

  vec3 col = vec3(0.0);

  const vec3 baseCol = vec3(240.0, 175.0, 20.0)/255.0;

  col += 0.9*baseCol*vec3(smoothstep(smoothPixel, -smoothPixel, d));

  vec3 rgb = 0.5 + 0.5*vec3(sin(TAU*vec3(50.0, 49.0, 48.0)*(d - 0.050) + ltime*TAU/3.0));

  col += baseCol.xyz*pow(rgb, vec3(8.0, 9.0, 7.0));
  col *= 1.0 - tanh(0.05+length(8.0*d));

  ltime -= 1.25;
  float phase = TAU/4.0*(-length(p) - 0.5*p.y) + ltime*TAU/11.0;

  float wave = sin(phase);
  float fwave = sign(wave)*pow(abs(wave), 0.75);

  col = abs(0.79*(0.5 + 0.5*fwave) - col);
  col = pow(col, vec3(0.25, 0.5, 0.75));

  col = acid_postProcess(col, q, p);

  return col;
}

#endif

// -------------------------------==> ACID <==---------------------------------

// -------------------------------==> SMEAR <==--------------------------------

#ifdef ENABLE_SMEAR

float smear_df(vec2 p, float time) {
  return cogImpulse(p, time);
}

vec3 smear_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float time = ltime + input0;
  float ttime = TAU*time;
  p *= 1.65;
  vec3 col = vec3(1.0);

  float z = 0.9 - ltime*0.025;

  float d = smear_df(p/z, time)*z;
  p += -0.025*time*vec2(-1.0, 1.0);

  vec2 v;
  vec2 w;
  float f = warped_warp(p, ttime, d, 1.0, v, w);
  vec3 n = warped_normal(p, ttime, d, 1.0);

  vec3 lig = normalize(vec3(0.6, -0.4, -0.4));
//  rot(lig.xz, ttime/100.0);
  float dif = max(dot(lig, n), 0.5);

  const vec3 col1 = vec3(0.1, 0.3, 0.8);
  const vec3 col2 = vec3(0.7, 0.3, 0.5);

  float c1 = dot(normalize(lig.xz), v)/length(v);
  float c2 = dot(normalize(lig.xz), w)/length(w);

  col = pow(dif, 0.75)*tanh(pow(abs(f + 0.5), 1.5)) + c1*col1 + c2*col2;
  col += 0.25*vec3(smoothstep(0.0, -0.0125, d));

  col = postProcess(col, q);

  return col;
}

#endif

// -------------------------------==> SMEAR <==--------------------------------

// ------------------------------==> GLOWBALL <==------------------------------

#ifdef ENABLE_GLOWBALL

const float glowball_period = 600.0;

vec3 glowball_lightning(vec2 pos, float ptime, float offset) {
  vec3 col = vec3(0.0);
  vec2 f = 10.0*SCA(PI/2.0 + ptime);

  for (int i = 0; i < 3; i++) {
    float btime = 85.0*ptime + float(i);
    float rtime = 75.0*ptime + float(i) + 10.0;
    float d1 = abs(offset * 0.03 / (0.0 + offset - soft_fbm((pos + f) * 3.0, rtime)));
    float d2 = abs(offset * 0.03 / (0.0 + offset - soft_fbm((pos + f) * 2.0, btime)));
    col += vec3(d1 * vec3(0.1, 0.3, 0.8));
    col += vec3(d2 * vec3(0.7, 0.3, 0.5));
  }

  return col;
}

float glowball_df(vec2 p, float time) {
  float ptime = time*TAU/glowball_period;
  float z = 0.125 + 0.125*(0.5 - 0.5*cos(20.0*ptime));
  return cogImpulse(p/z,  time)*z;
}

vec3 glowball_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  ltime += input0;
  float ptime = ltime*TAU/glowball_period;

  float d = glowball_df(p, ltime);

  const vec3  background   = vec3(0.0)/vec3(255.0);

  vec3 col = background;

  float borderStep = 0.0075;

  vec3 baseCol = vec3(1.0);
  vec4 logoCol = vec4(baseCol, 1.0)*smoothstep(-borderStep, 0.0, -d);

  if (d >= 0.0) {
    vec2 pp = toPolar(p);
    float funky = 0.7*pow((0.5 - 0.5*cos(ptime)), 4.0);
    pp.x *= 1./(pow(length(p) + funky, 15.0) + 1.0);
    p = toRect(pp);
    col += glowball_lightning(p, ptime, (pow(abs(d), 0.25 + 0.125*sin(0.5*ltime + p.x + p.y))));
  }

  col = clamp(col, 0.0, 1.0);

  col *= 1.0 - logoCol.xyz;

  col = postProcess(col, q);

  return col;
}

#endif

// ------------------------------==> GLOWBALL <==------------------------------

// -------------------------------==> DREAMS <==-------------------------------

#ifdef ENABLE_DREAMS

vec3 dreams_lightning(vec2 pos, float ttime, float offset, float dl) {
  vec3 col = vec3(0.0);
  vec2 f = 10.0*SCA(PI/2.0 + ttime/1000.0);

  float width = 0.003*dl;

  for (int i = 0; i < 2; i++) {
    float btime = ttime/35.0 + float(i);
    float rtime = ttime/40.0 + float(i) + 10.0;
    float d1 = abs(offset * width / (0.0 + offset - soft_fbm((pos + f) * 3.0, rtime)));
    float d2 = abs(offset * width / (0.0 + offset - soft_fbm((pos + f) * 2.0, btime)));
    col += vec3(d1 * vec3(0.1, 0.3, 0.8));
    col += vec3(d2 * vec3(0.7, 0.3, 0.5));
  }

  return clamp(col, 0.0, 1.0);;
}

float dreams_tile0(vec2 p, float hwidth, float lwidth) {
  float c0 = circle(p - vec2(hwidth), hwidth);
  float c1 = circle(p + vec2(hwidth), hwidth);
  c0 = abs(c0) - lwidth;
  c1 = abs(c1) - lwidth;

  float d = c0;
  d = min(d, c1);

  return d;
}

float dreams_tile(vec2 p, vec2 n, float hwidth, float lwidth) {
  float rnd = hash(1000.0*n).x;

  rot(p, float(int(mod(1000.0*rnd, 4.0)))*PI/2.0);

  float d = dreams_tile0(p, hwidth, lwidth);

  return d;
}

float dreams_df(vec2 p) {
  float hwidth = 1.0;
  float lwidth = 0.25;
  vec2 n = mod2(p, vec2(hwidth*2.0));
  float d = dreams_tile(p, n, hwidth, lwidth);

  return d;
}

vec2 dreams_coordinateTransform(vec2 p, float ttime) {
  vec2 op = p;
  p.x = SABS(p.x, 0.1);
  p *= 5.0;
  rot(p, ttime/100.0);
  vec2 sp = toSmith(p);
  float x = PI;
  sp.x += x;
  sp.y += x;
  p = fromSmith(sp);
  return p;
}

vec4 dreams_dCoordinateTransform(vec2 p, float ttime) {
  vec4 nor;
  vec2 eps = vec2(0.0001, 0.0);

  nor.xy = (dreams_coordinateTransform(p + eps.xy, ttime) - dreams_coordinateTransform(p - eps.xy, ttime));
  nor.zw = (dreams_coordinateTransform(p + eps.yx, ttime) - dreams_coordinateTransform(p - eps.yx, ttime));

  return nor/eps.x;
}

vec3 dreams_postProcess(vec3 col, vec2 p, vec2 q) {
  float l = length(p);
  col=pow(clamp(col,0.0,1.0),(l+0.5)*vec3(0.75, 0.9, 0.25));
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4+0.5*l);  // satuation
  col*=0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
  return col;
}

vec3 dreams_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float ttime = TAU*(ltime + input0);
  vec2 op = p;
  float z = 0.5;

  vec3 col = vec3(0.0);

  vec4 dp = dreams_dCoordinateTransform(p, ttime);
  float dl = length(dp);
  p = dreams_coordinateTransform(p, ttime);
  p.y += ttime/200.0;

  float d = dreams_df(p/z)*z;

  const float pp = 0.3;
  vec3 li = dreams_lightning(p, ttime, tanh(pow(max(d, 0.0), pp)), 20.0*pow(1.5*dl, pp));
  col = 1.0 - li;

  float f = tanh(0.01*dl);
  col = pow(col, vec3(1.0 - f))*vec3(1.2, 0.7, 0.5);
  col = clamp(col, 0.0, 1.0);
  col = mix(col, vec3(0.), f);

  col = dreams_postProcess(col, op, q);

  return col;
}

#endif

// -------------------------------==> DREAMS <==-------------------------------

// --------------------------------==> FORT <==--------------------------------

#ifdef ENABLE_FORT

float fort_nfield(vec2 p, vec2 c) {
  vec2 u = p;

  float a = 0.0;
  float s = 1.0;


  for (int i = 0; i < 25; ++i) {
    float m = dot(u,u);
    u = SABS(u, 0.0125)/m + c;
    u *= pow(s, 0.65);
    a += s*m;
    s *= 0.75;
  }

  return -tanh(0.125*a);
}

vec3 fort_normal(vec2 p, vec2 c) {
  vec2 v;
  vec2 w;
  vec2 e = vec2(0.00005, 0);

  vec3 n;
  n.x = fort_nfield(p + e.xy, c) - fort_nfield(p - e.xy, c);
  n.y = 2.0*e.x;
  n.z = fort_nfield(p + e.yx, c) - fort_nfield(p - e.yx, c);

  return normalize(n);
}

vec3 fort_field(vec2 p, vec2 c, float ttime) {
  vec2 u = p;

  float a = 0.0;
  float s = 1.0;

  vec2 tc = vec2(0.5, 0.3);
  rot(tc, ttime/30.0);
  vec2 tpn = normalize(vec2(1.0));
  float tpm = 0.0 + 1.4*tanh(length(p));

  float tcd = 1E10;
  float tcp = 1E10;

  for (int i = 0; i < 18; ++i) {
    float m = dot(u,u);
    u = SABS(u, 0.0125)/m + c;
    tcd = min(tcd, holey(circle(u-tc, 0.05), -0.1));
    tcp = min(tcp, holey(plane(u, tpn, tpm), -0.1));
    u *= pow(s, 0.5);
    a += pow(s, 1.0)*m;
    s *= 0.75;
  }

  return vec3(tanh(0.125*a), tanh(tcd), tanh(tcp));

}

vec3 fort_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  p *= input0;

  float ttime = TAU*ltime;
  float scale = input1  + 0.05*ltime/effectDuration;
//  vec2 c = (vec2(-0.5, -0.45)-0.15*pow((1.0-q.y)*1.25, 0.5))*scale;
  vec2 c = vec2(-0.5, -0.35)*scale;

  vec3 gp = vec3(p.x, 1.0*tanh(1.0 - (length(p))), p.y);
  vec3 lp1 = vec3(-1.0, 1.5, 1.0);
  vec3 ld1 = normalize(lp1 - gp);
  vec3 lp2 = vec3(1.0, 1.5, 1.0);
  vec3 ld2 = normalize(lp2 - gp);
  vec3 f = fort_field(p, c, ttime);

  vec3 n = fort_normal(p, c);

  float diff1 = max(dot(ld1, n), 0.0);
  float diff2 = max(dot(ld2, n), 0.0);

  vec3 col = vec3(0.0);

  const vec3 dcol1 = vec3(0.3, 0.5, 0.7).xyz;
  const vec3 dcol2 = 0.5*vec3(0.7, 0.5, 0.3).xyz;
  const vec3 scol1 = 0.5*vec3(1.0);
  const vec3 scol2 = 0.5*0.5*vec3(1.0);

  col += diff1*dcol1;
  col += diff2*dcol2;
  col += scol1*pow(diff1, 10.0);
  col += scol2*pow(diff2, 3.0);
  col -= vec3(tanh(f.y-0.1));
  col += 0.5*(diff1+diff2)*(1.25*pow(vec3(f.z), 5.0*vec3(1.0, 4.0, 5.0)));

  col = postProcess(col, q);

  return col;
}

#endif

// --------------------------------==> FORT <==--------------------------------

// ------------------------------==> JUPYTER <==-------------------------------

#ifdef ENABLE_JUPYTER

float jupyter_df(vec2 p) {
  float d = length(p) - 1.66;
  return d;
}

vec3 jupyter_warp(vec2 p, vec2 q, vec3 lig, float ttime, float d) {
  vec3 col;
  vec2 v;
  vec2 w;

  float f = warped_warp(p, ttime, d, 0.0, v, w);
  vec3 n = warped_normal(p, ttime, d, 0.0);

  float td = tanh(d);

  f *= td;
  v *= td;
  w *= td;

  float dif = max(dot(lig, n), 0.5);

  const vec3 col11 = vec3(0.1, 0.3, 0.8);
  const vec3 col21 = vec3(0.7, 0.3, 0.1);
  const vec3 col12 = vec3(0.1, 0.5, 0.8);
  const vec3 col22 = vec3(0.7, 0.3, 0.5);

  vec3 col1 = mix(col11, col12, q.x);
  vec3 col2 = mix(col21, col22, q.y);

  return pow(dif, 0.75)*tanh(pow(abs(f + 0.5), 1.5)) + (length(v)*col1 + length(w)*col2);
}

vec3 jupyter_planet(vec2 p, vec2 q, float ltime, float ttime) {
  float smoothPixel = 10.0/RESOLUTION.y;

  float z = 0.5;

  p /= z;

  float d = jupyter_df(p)*z;

  vec3 lig = normalize(vec3(0., 0.2, -0.4));
  rot(lig.xy, ttime/10.0);
  vec3 col = jupyter_warp(p, q, lig, ttime, d);

  col *= pow(max(-d, 0.0), 0.5);
  col += vec3(1.0 - pow(smoothstep(0.0, 0.2, -d), 0.5))*0.25*vec3(0.0, 0.0, 1.0);
  col += vec3(1.0 - pow(smoothstep(0.0, 0.1, -d), 0.25))*1.5*vec3(1.0, 0.8, 0.8);
  vec3 ccol = vec3(1.0 - pow(smoothstep(0.0, 0.2, d), 0.25))*2.0*vec3(1.0, 0.8, 0.8);

  col = mix(col, ccol, smoothstep(0.0, smoothPixel, d));

  return col;
}

vec3 jupyter_flat(vec2 p, vec2 q, float ltime, float ttime) {
  p += ltime*0.0125;
  p *= 2.0 - ltime*0.0125;
  rot(p, (ltime-effectDuration)*TAU/900.0);

  vec3 lig = normalize(vec3(0., 0.2, -0.4));
  rot(lig.xy, ttime/10.0);
  vec3 col = jupyter_warp(p, q, lig, ttime, 1.0);

  col = clamp(col, 0.0, 1.0);
  col = pow(col, vec3(1.5, 2.5, 3.5));

  return col;
}

vec3 jupyter_mirror(vec2 p, vec2 q, float ltime, float ttime) {
  p*=2.0 - ltime*0.0125;
  p.x = SABS(p.x, 0.125);
  p.y *= -1.0;

  vec3 lig = normalize(vec3(0.2, 0.2, -0.2));
  vec3 col = jupyter_warp(p, q, lig, ttime, 1.0);

  col = clamp(col, 0.0, 1.0);
  col = pow(col, vec3(1.5, 2.5, 3.5)*1.5);

  return col;
}

vec3 jupyter_kaleido(vec2 p, vec2 q, float ltime, float ttime) {
  p += ltime*0.0125;
  p *= 2.0 - ltime*0.0125;
  rot(p, (ltime-effectDuration)*TAU/900.0);

  vec2 pp = toPolar(p);
  modMirror1(pp.y, PI/15.0);
  p = toRect(pp);

  vec3 lig = normalize(vec3(0.2, 0.2, 0.2));
//  rot(lig.xz, ttime/effectDuration);
  vec3 col = jupyter_warp(p, q, lig, ttime, 1.0);

  col = clamp(col, 0.0, 1.0);
  col = pow(col, vec3(1.5, 2.5, 3.5));

  return col;
}

vec3 jupyter_effect(int minor, float input0, float input1, float gtime, float ltime, vec2 p, vec2 q) {
  float ttime = (ltime + input0)*TAU;

  vec3 col = vec3(0.5);

  switch(minor) {
  case MINOR_PLANET:
    col = jupyter_planet(p, q, ltime, ttime);
    break;
  case MINOR_FLAT:
    col = jupyter_flat(p, q, ltime, ttime);
    break;
  case MINOR_MIRROR:
    col = jupyter_mirror(p, q, ltime, ttime);
    break;
  case MINOR_KALEIDO:
    col = jupyter_kaleido(p, q, ltime, ttime);
    break;
  default:
    col = vec3(0.5, 0.0, 0.0);
  }

  col = postProcess(col, q);
  return col;
}

#endif

// ------------------------------==> JUPYTER <==-------------------------------

// -------------------------------==> MAIN <==---------------------------------

void mainImage(out vec4 fragColor, vec2 p, vec2 q) {
  p.x *= RESOLUTION.x/RESOLUTION.y;

  const float effectNo = 0.0;

  float dtime = TIME - startDelay;

  float timeInEffect = mod(dtime, effectDuration);
  int effectIndex = int(effectNo + mod(dtime/effectDuration, float(effects.length())));
  Effect effect = effects[effectIndex];
  Effect nextEffect = effects[int(effectIndex + 1% effects.length())];

  vec3 col = vec3(0.5);

  float ltime = timeInEffect + effect.seq*effectDuration;

  switch(effect.major) {
#ifdef ENABLE_TUNNEL
  case MAJOR_TUNNEL:
    col = tunnel_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_IMPULSE
  case MAJOR_IMPULSE:
    col = impulse_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_DRAGON
  case MAJOR_DRAGON:
    col = dragon_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_ACID
  case MAJOR_ACID:
    col = acid_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_SMEAR
  case MAJOR_SMEAR:
    col = smear_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_GLOWBALL
  case MAJOR_GLOWBALL:
    col = glowball_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_DREAMS
  case MAJOR_DREAMS:
    col = dreams_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_FORT
  case MAJOR_FORT:
    col = fort_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
#ifdef ENABLE_JUPYTER
  case MAJOR_JUPYTER:
    col = jupyter_effect(effect.minor, effect.input0, effect.input1, dtime, ltime, p, q);
    break;
#endif
  default:
    col = vec3(0.5, 0.0, 0.0);
    break;
  }

  float fadeIn = (1.0 - smoothstep(0.0, fadeTime, timeInEffect));
  float fadeOut = smoothstep(effectDuration - fadeTime, effectDuration, timeInEffect);

  vec2 fp = p;
  vec3 fadeCol = pow(vec3(0.5), vec3(0.0, fp.x, -fp.y)) + vec3(0.5)*(fadeIn + fadeOut);

  if (effect.seq == 0.0) {
    col += fadeCol*fadeIn*fadeIn;
  }

  if (nextEffect.seq == 0.0){
    col += fadeCol*pow(fadeOut, 30.0);
  }

  col = clamp(col, 0.0, 1.0);

  float initialFade = smoothstep(0.5, effectDuration, dtime);
  float exitFade = 1.0 - smoothstep(float(effects.length() - 1)*effectDuration, min(songLength-startDelay, effects.length()*effectDuration), dtime);

#ifndef EXPERIMENTING
  col *= sqrt(initialFade);
  col *= sqrt(exitFade);
#endif

  fragColor = vec4(col.xyz, 1.0);
}

// -------------------------------==> MAIN <==---------------------------------