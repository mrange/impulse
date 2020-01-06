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

layout (location=2) uniform sampler2D texture0;
layout (location=3) uniform sampler2D texture1;

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

// -----------------------------==>> COMMON <<==--------------------------------

#define PI          3.141592654
#define TAU         (2.0*PI)
#define FADEPERIOD  22.0
#define PERIOD      (int(time/FADEPERIOD))
#define TIME        (mod(time, FADEPERIOD))

float softMin(float a, float b, float k) {
  float res = exp(-k*a) + exp(-k*b);
  return -log(res)/k;
}

vec3 expSoftMin3(vec3 a, vec3 b, vec3 k) {
  vec3 res = exp(-k*a) + exp(-k*b);
  return -log( res )/k;
}

vec3 polySoftMin3(vec3 a, vec3 b, vec3 k) {
  vec3 h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0);
  
  return mix(b, a, h) - k*h*(1.0-h);
}

vec3 powSoftMin3(vec3 a, vec3 b, vec3 k) {
  a = pow(a, k); 
  b = pow(b, k);
  return pow( (a*b)/(a+b), 1.0/k );
}

void rot(inout vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  p = vec2(c*p.x + s*p.y, -s*p.x + c*p.y);
}

float impulse1(vec2 p) {
  ivec2 ivec = textureSize(texture0, 0);
  p.x *= float(ivec.y)/ivec.x;
  p.y = -p.y;
  p*=1.0;
  p+=vec2(1.00, 1.00);
  p*=0.5;
  vec4 t = texture(texture0, p);
  float d = t.x + (1.0/256.0)*t.y + (1.0/(256.0*256.0))*t.z;
  return -2.0*d + 1.0;
}

float impulse2(vec2 p) {
  ivec2 ivec = textureSize(texture1, 0);
  p.x *= float(ivec.y)/ivec.x;
  p.y = -p.y;
  p*=1.0;
  p+=vec2(1.08, 1.00);
  p*=0.5;
  vec4 t = texture(texture1, p);
  float d = t.x + (1.0/256.0)*t.y + (1.0/(256.0*256.0))*t.z;
  return -2.0*d + 1.0;
}

float box(vec3 p, vec3 b)
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float box(vec2 p, vec2 b) {
  vec2 d = abs(p)-b;
  return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float circle(vec2 p, float r) {
  return length(p) - r;
}

float parabola(vec2 pos, float k) {    
  pos.x = abs(pos.x);
    
  float p = (1.0-2.0*k*pos.y)/(6.0*k*k);
  float q = -abs(pos.x)/(4.0*k*k);
    
  float h = q*q + p*p*p;
  float r = sqrt(abs(h));

  float x = h > 0.0
    ? pow(-q+r,1.0/3.0) - pow(abs(-q-r),1.0/3.0)*sign(q+r) 
    : 2.0*cos(atan(r,-q)/3.0)*sqrt(-p)
    ;
    
  return length(pos-vec2(x,k*x*x)) * sign(pos.x-x);
}

float unevenCapsule(vec2 p, float r1, float r2, float h) {
  p.x = abs(p.x);
  float b = (r1-r2)/h;
  float a = sqrt(1.0-b*b);
  float k = dot(p,vec2(-b,a));
  if( k < 0.0 ) return length(p) - r1;
  if( k > a*h ) return length(p-vec2(0.0,h)) - r2;
  return dot(p, vec2(a,b) ) - r1;
}

float sphere(vec3 p, float t) {
  return length(p)-t;
}

float torus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
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

vec2 toRect(vec2 p) {
  return vec2(p.x*cos(p.y), p.x*sin(p.y));
}

vec2 toPolar(vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}

vec2 mod2(inout vec2 p, vec2 size)  {
  vec2 c = floor((p + size*0.5)/size);
  p = mod(p + size*0.5,size) - size*0.5;
  return c;
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
  p *= mod(c, 2.0)*2 - 1;
  return c;
}


vec2 modMirror2(inout vec2 p, vec2 size) {
  vec2 halfsize = size*0.5;
  vec2 c = floor((p + halfsize)/size);
  p = mod(p + halfsize, size) - halfsize;
  p *= mod(c,vec2(2))*2 - vec2(1);
  return c;
}

vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2 (269.5, 183.3)));

  return -1. + 2.*fract(sin(p)*43758.5453123);
}

float noise(vec2 p) {
  const float K1 = .366025404;
  const float K2 = .211324865;

  vec2 i = floor(p + (p.x + p.y)*K1);
   
  vec2 a = p - i + (i.x + i.y)*K2;
  vec2 o = step(a.yx, a.xy);    
  vec2 b = a - o + K2;
  vec2 c = a - 1. + 2.*K2;

  vec3 h = max(.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), .0);

  vec3 n = h*h*h*h*vec3(dot(a, hash(i + .0)), dot(b, hash(i + o)), dot(c, hash(i + 1.)));

  return dot(n, vec3(70.));
}

const float fadeRep = 0.05;
float fadef(vec2 p, vec2 j) {
  float localTime = TIME;
  j = toPolar(j);
  j.y += PI*length(j*fadeRep) - TAU*localTime;
  j = toRect(j);
  const float o = 0.25;
  float tt = localTime + 0.005*(j.x + 1.5*j.y);  
  return smoothstep(FADEPERIOD - 1.0 - o, FADEPERIOD - o, tt) + smoothstep(1.0 + o, 0.0 + o, tt);
}

vec3 fade(vec3 col, vec2 p) {
  const vec3 fcol = vec3(1.0);
  const float bw = 0.00125;
  vec2 pp = p ;
  
  vec2 j = mod2(pp, vec2(fadeRep));
  float ff = fadef(p, j);
  float d = circle(pp, (sqrt(0.5)*fadeRep)*ff);
  
  col = mix(col, fcol, step(4.0, time)*step(time, 210)*step(0.0001, ff)*smoothstep(bw, -bw, d));
  col *= smoothstep(0.0, 4.0, time)*smoothstep(220, 210, time);
  
  return col;
}

float fbm(vec2 p, float time) {
  float c =  cos(time/sqrt(3.0));
  float d =  noise (p                 );
  d += .5*   noise (p + vec2(+c  ,+0.0));
  d += .25*  noise (p + vec2(+0.0,+c  ));
  d += .125* noise (p + vec2(-c  ,+0.0));
  d += .0625*noise (p + vec2(+0.0,-c  ));
  d /= (1. + .5 + .25 + .125 + .0625);
  return .5 + .5*d;
}

vec3 saturate(vec3 col) {
  return clamp(col, 0.0, 1.0);
}

// -----------------------------==>> COMMON <<==--------------------------------

// ----------------------------==>> IMPULSE <<==--------------------------------

vec3 impulse_lightning(vec2 p, float d)
{
  const float thickness = 0.25;
  const float haze = 2.5;
  const float size = .075;
  const int count = 3;

  vec3 col = vec3(0.0);

  float e1 = 1.6 + 0.4*sin(time*sqrt(2.0));
  float e2 = e1;
  
//  float o = pow(d, 1.0);
  float o = d;

  for (int i = 0; i < count; ++i)
  {
    float fi = float(i);
    float localTime = time + fi;
    float fe1 = (pow(fi + 1.0, 0.2))*e1;
    float fe2 = fe1;
    vec2 o1 = 1.5*localTime*vec2(0.0, -1);
    vec2 o2 = o1;
    
    vec2 fp1 = p + o1;
    vec2 fp2 = p + o2;
    float d1 = abs ((o*haze)*thickness / (o - fe1*fbm (fp1, localTime*0.11)));
    float d2 = abs ((o*haze)*thickness / (o - fe2*fbm (fp2, localTime*0.09+0.75)));
    col += d1*size*vec3 (.1, .8, 2.);
    col += d2*size*vec3 (2., .1, .8);
  }

  col /= float(count-1);

  return col;
}

float impulse_appear(vec2 p) {
  float localTime = TIME*16.0/22.0;
  float o = 1.5*localTime - 0.25;
  float l = smoothstep(3.5, 8.0, localTime)*smoothstep(17.0, 13.0, localTime);
  float d0 = impulse1(p) + mix(2.0, 0.55, l) + -0.25*p.y;
  float d1 = parabola(p - vec2(0.0, 6.0-o), 0.5);
  float d2 = parabola(p - vec2(0.0, 9.0-o), 1.0);
  float d = max(d1, -d2 + 0.5);
  d = min(d, d0);
  return d;
}

float impulse_window(vec2 p) {
  const float r = 2.7;
  float d0 = -circle(p, r);
  vec2 bp = p;
  bp = toPolar(bp);
  bp.y += time*0.125;
  mod1(bp.y, TAU/3.0);
  bp = toRect(bp);
  const float bs = 0.3;
  bp -= vec2(r - 1.0*bs, 0.0);
  float d1 = box(bp, vec2(bs)) - 0.2;
  float d2 = 1.0*impulse2(0.9*p) + 0.7 - 0.3*p.y;
  p -= vec2(0.0, -1.5);
  mod1(p.y, 3.0);
  float d = d0;
  d = softMin(d, d1, 10.0);
  d = min(d, d2);
  return d;
}

float impulse_df(vec2 p) {
  switch(PERIOD) {
  default:
  case 0: return impulse_appear(p);
  case 5: return impulse_window(p);
  }
}

vec3 impulse_main(vec2 p, vec2 q) {
  p*=1.75;

  float d = impulse_df(p);
  float lf = 1.65*(d + 0.125);
  vec3 l = impulse_lightning(p, lf);

  d*=150.0;  
  const vec3 baseCol = vec3(0.5, 0.35, 0.8);
  vec3 col = 0.0*baseCol;
  
  col += baseCol*smoothstep(1.0, -1.0, d);
  col += vec3(0.55)*smoothstep(0.0, -32.0, d);
  col += vec3(1.0)*smoothstep(-3.0, -2.0, d)*smoothstep(3.0, 2.0, d);
  col += baseCol*0.66*step(0.0, d)*exp(-d*d*0.001);

  col += l;
  
  return col;
}

// ----------------------------==>> IMPULSE <<==--------------------------------

// -----------------------==>> INFINITE COGWHEELS <<==--------------------------

const float infcw_cogRadius = 0.02;
const float infcw_smallWheelRadius = 0.30;
const float infcw_bigWheelRadius = 0.55;
const float infcw_wheelOffset = infcw_smallWheelRadius + infcw_bigWheelRadius - infcw_cogRadius;
const vec3 infcw_baseCol = vec3(240.0, 115.0, 51.0)/vec3(255.0);

float infcw_smallCogwheel(vec2 p) {
  float dc = circle(p, 0.25);  
  vec2 pp = toPolar(p);
  pp.y += time*2 + TAU/32;
  vec2 cpp = pp;
  mod1(cpp.y, TAU/16.0);
  cpp.y += PI/2.0;
  vec2 cp = toRect(cpp);
  float ds = unevenCapsule(cp, 0.05, infcw_cogRadius, infcw_smallWheelRadius);
  float dcw = softMin(ds, dc, 100.0);
  float dic = circle(p, 0.11/2);
  vec2 ipp = pp;
  mod1(ipp.y, TAU/6.0);
  vec2 ip = toRect(ipp);
  float dic2 = circle(ip - vec2(0.15, 0.0), 0.11/2);
  float di = min(dic, dic2);
  return max(dcw, -di);
}

float infcw_bigCogwheel(vec2 p) {
  float dc = circle(p, 0.5);  
  vec2 pp_ = toPolar(p);
  pp_.y += -time;
  vec2 cpp = pp_;
  mod1(cpp.y, TAU/32.0);
  cpp.y += PI/2.0;
  vec2 cp = toRect(cpp);
  float ds = unevenCapsule(cp, 0.1, infcw_cogRadius, infcw_bigWheelRadius);
  float dcw = softMin(ds, dc, 100.0);
  float dic = circle(p, 0.125);
  vec2 ipp = pp_;
  mod1(ipp.y, TAU/6.0);
  vec2 ip = toRect(ipp);
  float dic2 = circle(ip - vec2(0.3, 0.0), 0.125);
  float di = min(dic, dic2);
  return max(dcw, -di);
}

float infcw_cogwheels(vec2 p) {
  p.x += infcw_wheelOffset*0.5;
  float dsc = infcw_smallCogwheel(p - vec2(infcw_wheelOffset, 0.0));
  float dbc = infcw_bigCogwheel(p);
  return min(dsc, dbc);
}

float infcw_df(vec2 p) {
  float i = mod1(p.x, infcw_wheelOffset);
  float s = mod(i, 2.0)*2.0 - 1.0;
  p *= s;
  float dcs = infcw_cogwheels(p);
  return dcs;
}

vec4 infcw_sample(float localTime, vec2 p, int i) {
  float borderStep = 0.00125;
  vec3 col = infcw_baseCol;  
  p *= 4.0;
  rot(p, TAU*float(i)/250.0 + TAU*localTime*0.01);
  float d = infcw_df(p);
  float d2 = abs(d) - 0.025;
  if (d < d2) col = pow(infcw_baseCol, vec3(0.6));
  float t = smoothstep(-borderStep, 0.0, -d);
  t *= exp(-dot(p, p)*0.0025);
  return vec4(col, t);
}


vec3 infcw_main(vec2 p, vec2 q) {
  int period = PERIOD;
  float localTime = TIME + 166;
  
  float shadeF = 0.25;
  float zf = pow(0.9, 20.0*(0.5+0.5*cos(localTime*sqrt(0.03))));
  p = vec2(0.5, -0.05) + p*0.75*zf;

  vec3 col = vec3(0.0);
  vec3 ss = mix(vec3(0.2, 0.2, 0.5), vec3(0.2,-0.2,1.0), 2.2 + 1.25*sin(localTime*0.5));

  vec2 c = vec2(-0.76, 0.15);
  rot(c, 0.2*sin(localTime*sqrt(3.0)/12.0));
  float f = 0.0;
  vec2 z = p;

  float transparency = 1.0;

  vec3 bg = vec3(0.0);

  float minTrap = 10000.0;

  const int maxIter = 85;
  const float maxIterF = float(maxIter);
  for(int i=0; i<maxIter; ++i)
  {
    float re2 = z.x*z.x;
    float im2 = z.y*z.y;
    if((re2 + im2>4.0) || (transparency<0.2)) break;
    float reim = z.x*z.y;

    z = vec2(re2 - im2, 2.0*reim) + c;
    minTrap = min(minTrap, length(z - c));

    float fi = f/maxIterF;
    float shade = sqrt(1.0-0.9*fi);

    vec4 sample_ = infcw_sample(localTime, ss.xy + ss.z*z, i);
    float ff = mix(0.0, 0.5, pow(fi, 0.5));
    sample_.xyz = pow(sample_.xyz, mix(vec3(1.0), vec3(75.0, 0.5, 0.0), ff));
    sample_.w *= shade;
   
    col += sample_.xyz*sample_.w*transparency; 
    transparency *= (1.0 - clamp(sample_.w, 0.0, 1.0));
    
    f += 1.0;
  }
  
  bg= vec3(0.3, 0.25, 0.4)*max(0.5 - sqrt(minTrap), 0.0);
  col = mix(col, bg, transparency);
  return col;
}

// -----------------------==>> INFINITE COGWHEELS <<==--------------------------

// ----------------------------==>> MANDALA <<==--------------------------------

float mandala_df(float localTime, vec2 p) {
  vec2 pp = toPolar(p);
  float a = TAU/64.0;
  float np = pp.y/a;
  pp.y = mod(pp.y, a);
  float m2 = mod(np, 2.0);
  if (m2 > 1.0) {
    pp.y = a - pp.y;
  }
  pp.y += localTime/40.0;
  p = toRect(pp);
  p = abs(p);
  p -= vec2(0.5);
  
  float d = 10000.0;
  
  for (int i = 0; i < 4; ++i) {
    mod2(p, vec2(1.0));
    float da = -0.2 * cos(localTime*0.25);
    float sb = box(p, vec2(0.35)) + da ;
    float cb = circle(p + vec2(0.2), 0.25) + da;
    
    float dd = max(sb, -cb);
    d = min(dd, d);
    
    p *= 1.5 + 1.0*(0.5 + 0.5*sin(0.5*localTime));
    rot(p, 1.0);
  }

  
  return d;
}

vec3 mandala_postProcess(float localTime, vec3 col, vec2 uv) 
{
  float r = length(uv);
  float a = atan(uv.y, uv.x);
  col = clamp(col, 0.0, 1.0);   
  col=pow(col,mix(vec3(0.5, 0.75, 1.5), vec3(0.45), r)); 
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4);  // satuation
  col*=sqrt(1.0 - sin(-localTime + (50.0 - 25.0*sqrt(r))*r))*(1.0 - sin(0.5*r));
  col = clamp(col, 0.0, 1.0);
  float ff = pow(1.0-0.75*sin(20.0*(0.5*a + r + -0.1*localTime)), 0.75);
  col = pow(col, vec3(ff*0.9, 0.8*ff, 0.7*ff));
  col *= 0.5*sqrt(max(4.0 - r*r, 0.0));
  return clamp(col, 0.0, 1.0);
}

vec2 mandala_distort(float localTime, vec2 uv) {
  float lt = 0.1*localTime;
  vec2 suv = toSmith(uv);
  suv += 1.0*vec2(cos(lt), sin(sqrt(2.0)*lt));
//  suv *= vec2(1.5 + 1.0*sin(sqrt(2.0)*time), 1.5 + 1.0*sin(time));
  uv = fromSmith(suv);
  modMirror2(uv, vec2(2.0+sin(lt)));
  return uv;
}

vec3 mandala_sample(float localTime, vec2 p, vec2 q)
{
  float lt = 0.1*localTime;
  vec2 uv = p;
  uv *=8.0;
  rot(uv, lt);
  //uv *= 0.2 + 1.1 - 1.1*cos(0.1*iTime);

  vec2 nuv = mandala_distort(localTime, uv);
  vec2 nuv2 = mandala_distort(localTime, uv + vec2(0.0001));

  float nl = length(nuv - nuv2);
  float nf = 1.0 - smoothstep(0.0, 0.002, nl);

  uv = nuv;
  
  float d = mandala_df(localTime, uv);

  vec3 col = vec3(0.0);
 
  const float r = 0.065;

  float nd = d / r;
  float md = mod(d, r);
  
  if (abs(md) < 0.025) {
    col = (d > 0.0 ? vec3(0.25, 0.65, 0.25) : vec3(0.65, 0.25, 0.65) )/abs(nd);
  }

  if (abs(d) < 0.0125) {
    col = vec3(1.0);
  }

  col += 1.0 - pow(nf, 5.0);
  
  col = mandala_postProcess(localTime, col, uv);;
  
  col += 1.0 - pow(nf, 1.0);

  return saturate(col);
}

vec3 mandala_main(vec2 p, vec2 q) {

  float to = 0.0;
  switch(PERIOD) {
  default:
  case 1:
    to = 32.0;
    break;
  case 7:
    to = 104;
    break;
  } 
  float localTime = 0.8 *TIME + to;
  vec3 col  = vec3(0.0);
  vec2 unit = 1.0/resolution.xy;
  const int aa = 2;
  for(int y = 0; y < aa; ++y)
  {
    for(int x = 0; x < aa; ++x)
    {
      col += mandala_sample(localTime, p - 0.5*unit + unit*vec2(x, y), q);
    }
  }

  col /= (aa*aa);
  return col;
}
// ----------------------------==>> MANDALA <<==--------------------------------

// ---------------------------==>> MANDELBONE <<==------------------------------

const float mandelbone_max_distance  = 40.0;
const float mandelbone_eps           = 0.001;
const float mandelbone_tolerance     = 0.0003;
const float mandelbone_fixed_radius2 = 1.9;
const float mandelbone_min_radius2   = 0.5;
const float mandelbone_folding_limit = 1.0;
const float mandelbone_scale         = -2.8;
const int   mandelbone_max_iter      = 120;
const vec3  mandelbone_bone          = vec3(0.89, 0.855, 0.788);

void mandelbone_sphereFold(inout vec3 z, inout float dz) {
    float r2 = dot(z, z);
    if(r2 < mandelbone_min_radius2) {
        float temp = (mandelbone_fixed_radius2 / mandelbone_min_radius2);
        z *= temp;
        dz *= temp;
    } else if(r2 < mandelbone_fixed_radius2) {
        float temp = (mandelbone_fixed_radius2 / r2);
        z *= temp;
        dz *= temp;
    }
}

void mandelbone_boxFold(inout vec3 z, inout float dz) {
    const float k = 0.055;
    vec3 zz = sign(z)*polySoftMin3(abs(z), vec3(mandelbone_folding_limit), vec3(k));
//    vec3 zz = clamp(z, -folding_limit, folding_limit);
    z = zz * 2.0 - z;
}

float mandelbone_mandelbox(vec3 z) {
    vec3 offset = z;
    float dr = 1.0;
    float fd = 0.0;
    for(int n = 0; n < 5; ++n) {
        mandelbone_boxFold(z, dr);
        mandelbone_sphereFold(z, dr);
        z = mandelbone_scale * z + offset;
        dr = dr * abs(mandelbone_scale) + 1.0;        
        float r1 = sphere(z, 5.0);
        float r2 = torus(z, vec2(8.0, 1));        
        float r = n < 4 ? r2 : r1;        
        float dd = r / abs(dr);
        if (n < 3 || dd < fd) {
          fd = dd;
        }
    }
    return fd;
}

float mandelbone_apollian(vec3 p) {
  float s = 1.3 + smoothstep(0.15, 1.5, p.y)*0.95;
//  float s = 1.3 + min(pow(max(p.y - 0.25, 0.0), 1.0)*0.75, 1.5);
  float scale = 1.0;

  float r = 0.2;
  vec3 o = vec3(0.22, 0.0, 0.0);

  const int rep = 7;

  for (int i=0; i < rep ;++i) {
    mod1(p.y, 2.0);
    modMirror2(p.xz, vec2(2.0));
    rot(p.xz, PI/5.5);

    float r2 = dot(p,p) + 0.0;
    float k = s/r2;
    float r = 0.5;
    p *= k;
    scale *= k;
  }

  float db = box(p - 0.1, 1.0*vec3(1.0, 2.0, 1.0)) - 0.5;  
  float d = db;
  d = abs(d) - 0.01;
  return 0.25*d/scale;
}

float mandelbone_tree(vec3 p) { 
  float d1 = mandelbone_apollian(p);
  float db = box(p - vec3(0.0, 0.5, 0.0), vec3(0.75,1.0, 0.75)) - 0.5;
  float dp = p.y;
  return min(dp, max(d1, db)); 
} 

float mandelbone_mengercube(vec3 p)
{
  const float scale = 6.0;
  const vec3 offs = vec3(9.0);
  const float s = 3.;
  
  p *= scale;

  float d = 1e5;

  float amp = 1./s;

  for(int i = 0; i < 5; ++i){
    p = abs(p);

//    float ss = 0.125*s;
    p.xy += step(p.x, p.y)*(p.yx - p.xy);
    p.xz += step(p.x, p.z)*(p.zx - p.xz);
    p.yz += step(p.y, p.z)*(p.zy - p.yz);

    p = p*s + offs*(1. - s);

    p.z -= step(p.z, offs.z*(1. - s)*.5)*offs.z*(1. - s);

    float o = 2.0;
     rot(p.xy, PI/3);
     p = abs(p);
    float dd = box(p, vec3(o*8, o, o))*amp;
    d = min(d, dd);
    amp /= s;
  }

  return (d + 0.02)/scale;

}

float mandelbone_df(vec3 p) { 
  switch(PERIOD) {
  default:
  case 2:
  case 6:
    return mandelbone_mandelbox(p);
  case 4:
    return mandelbone_mengercube(p);
  case 8:
    return mandelbone_tree(p);
  }
} 

float mandelbone_intersect(vec3 ro, vec3 rd, float it, out int iter) {
    float res;
    float t = it;
    iter = mandelbone_max_iter;
    
    for(int i = 0; i < mandelbone_max_iter; ++i) {
        vec3 p = ro + rd * t;
        res = mandelbone_df(p);
        if(res < mandelbone_tolerance * t || res > mandelbone_max_distance) {
            iter = i;
            break;
        }
        t += res;
    }
    
    if(res > mandelbone_max_distance) t = -1.;
    return t;
}

float mandelbone_ambientOcclusion(vec3 p, vec3 n) {
  float stepSize = 0.012;
  float t = stepSize;

  float oc = 0.0;

  for(int i = 0; i < 12; i++) {
    float d = mandelbone_df(p + n * t);
    oc += t - d;
    t += stepSize;
  }

  return clamp(oc, 0.0, 1.0);
}

vec3 mandelbone_normal(in vec3 pos) {
  vec2  eps = vec2(mandelbone_eps,0.0);
  vec3 nor;
  nor.x = mandelbone_df(pos+eps.xyy) - mandelbone_df(pos-eps.xyy);
  nor.y = mandelbone_df(pos+eps.yxy) - mandelbone_df(pos-eps.yxy);
  nor.z = mandelbone_df(pos+eps.yyx) - mandelbone_df(pos-eps.yyx);
  return normalize(nor);
}

vec3 mandelbone_lighting(vec3 p, vec3 rd, int iter) {
  vec3 n = mandelbone_normal(p);
  float fake = float(iter)/float(mandelbone_max_iter);
  float fakeAmb = exp(-fake*fake*9);
  float amb = mandelbone_ambientOcclusion(p, n);

  vec3 col = vec3(mix(1.0, 0.125, pow(amb, 3.0)))*vec3(fakeAmb)*mandelbone_bone;
  return col;
}

vec3 mandelbone_post(vec3 col, vec2 q) {
  col=pow(clamp(col,0.0,1.0),vec3(0.65)); 
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.5);  // satuation
  col*=0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
  return col;
}

vec3 mandelbone_main(vec2 p, vec2 q)  {
  float ror = 0.57; // 0.57, 4.5

  float localTime = TIME;

  vec3 la = vec3(0.0, 0.75, 0.0); 
  vec3 ro = vec3(-4.0, 1.25, -0.0);

  switch(PERIOD) {
  default:
  case 6:
    localTime += 20.0;
  case 4:
    localTime += 14.0;
  case 2:
    localTime -= 56.0;
    float stime=sin(localTime*0.1); 
    float ctime=cos(localTime*0.1); 
    la = vec3(0.0,0.0,0.0); 
    ro = ror*vec3(3.0*stime,2.0*ctime,5.0+1.0*stime);
    break;
  case 8:
   rot(ro.xz, 2.0*PI*localTime/120.0);
   break;
  }

  vec3 cf = normalize(la-ro); 
  vec3 cs = normalize(cross(cf,vec3(0.0,1.0,0.0))); 
  vec3 cu = normalize(cross(cs,cf)); 
  vec3 rd = normalize(p.x*cs + p.y*cu + 3*cf);  // transform from view to world

  vec3 bg = mix(mandelbone_bone*0.5, mandelbone_bone, smoothstep(-1.0, 1.0, p.y));
  vec3 col = bg;

  int iter = 0;
  
  float t = mandelbone_intersect(ro, rd, 0.2, iter);
    
  if(t > -0.5) {
    vec3 p = ro + t * rd;
    col = mandelbone_lighting(p, rd, iter); 
    col = mix(col, bg, 1.0-exp(-0.001*t*t)); 
  } 
    

  col=mandelbone_post(col, q);
  return col;
}

// ---------------------------==>> MANDELBONE <<==------------------------------

// -----------------------------==>> SUNSET <<==--------------------------------

const float sunset_gravity = 1.0;
const float sunset_waterTension = 0.01;

/*
const vec3 sunset_skyCol1 = vec3(0.2, 0.4, 0.6);
const vec3 sunset_skyCol2 = vec3(0.4, 0.7, 1.0);
const vec3 sunset_sunCol  =  vec3(8.0,7.0,6.0)/8.0;
const vec3 sunset_seaCol1 = vec3(0.1,0.2,0.2);
const vec3 sunset_seaCol2 = vec3(0.8,0.9,0.6);
*/
const vec3 sunset_skyCol1 = vec3(0.6, 0.35, 0.3);
const vec3 sunset_skyCol2 = vec3(1.0, 0.3, 0.3);
const vec3 sunset_sunCol1 =  vec3(1.0,0.5,0.4);
const vec3 sunset_sunCol2 =  vec3(1.0,0.8,0.7);
const vec3 sunset_seaCol1 = vec3(0.1,0.2,0.2);
const vec3 sunset_seaCol2 = vec3(0.8,0.9,0.6);


float sunset_gravityWave(in vec2 p, float k, float h) {
  float w = sqrt(sunset_gravity*k*tanh(k*h));
  return sin(p.y*k + w*time);
}

float sunset_capillaryWave(in vec2 p, float k, float h) {
  float w = sqrt((sunset_gravity*k + sunset_waterTension*k*k*k)*tanh(k*h));
  return sin(p.y*k + w*time);
}

float sunset_seaHeight(in vec2 p) {
  float height = 0.0;

  float k = 1.0;
  float kk = 1.3;
  float a = 0.25;
  float aa = 1.0/(kk*kk);

  float h = 10.0;
  p *= 0.5;

  for (int i = 0; i < 3; ++i) {
    height += a*sunset_gravityWave(p + float(i), k, h);
    rot(p, float(i));
    k *= kk;
    a *= aa;
  }
  
  for (int i = 3; i < 7; ++i) {
    height += a*sunset_capillaryWave(p + float(i), k, h);
    rot(p, float(i));
    k *= kk;
    a *= aa;
  }

  return height;
}

vec3 seaNormal(in vec2 p, in float d) {
  vec2 eps = vec2(0.001*pow(d, 1.5), 0.0);
  vec3 n = vec3(
    sunset_seaHeight(p + eps) - sunset_seaHeight(p - eps),
    2.0*eps.x,
    sunset_seaHeight(p + eps.yx) - sunset_seaHeight(p - eps.yx)
  );
  
  return normalize(n);
}

vec3 sunset_sunDirection() {
  vec3 dir = normalize(vec3(0, 0.1, 1));
  return dir;
}

vec3 sunset_skyColor(vec3 rd) {
  vec3 sunDir = sunset_sunDirection();

  float sunDot = max(dot(rd, sunDir), 0.0);
  
  vec3 final = vec3(0.0);

  final += mix(sunset_skyCol1, sunset_skyCol2, rd.y);

  final += 0.5*sunset_sunCol1*pow(sunDot, 20.0);

  final += 4.0*sunset_sunCol2*pow(sunDot, 400.0);
    
  return final;
}

vec3 sunset_main(vec2 p, vec2 q)  {
  vec3 ro = vec3(0.0, 10.0, 0.0);
  vec3 ww = normalize(vec3(0.0, -0.1, 1.0));
  vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww));
  vec3 vv = normalize(cross(ww,uu));
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.5*ww);

  vec3 col = vec3(0.0);

  float dsea = (0.0 - ro.y)/rd.y;
  
  vec3 sunDir = sunset_sunDirection();
  
  vec3 sky = sunset_skyColor(rd);
    
  if (dsea > 0.0) {
    vec3 p = ro + dsea*rd;
    float h = sunset_seaHeight(p.xz);
    vec3 nor = mix(seaNormal(p.xz, dsea), vec3(0.0, 1.0, 0.0), smoothstep(0.0, 200.0, dsea));
    float fre = clamp(1.0 - dot(-nor,rd), 0.0, 1.0);
    fre = pow(fre, 3.0);
    float dif = mix(0.25, 1.0, max(dot(nor,sunDir), 0.0));
    
    vec3 refl = sunset_skyColor(reflect(rd, nor));
    vec3 refr = sunset_seaCol1 + dif*sunset_seaCol2*0.1; 
    
    col = mix(refr, 0.9*refl, fre);
      
    float atten = max(1.0 - dot(dsea,dsea) * 0.001, 0.0);
    col += sunset_seaCol2 * (p.y - h) * 2.0 * atten;
      
    col = mix(col, sky, 1.0 - exp(-0.01*dsea));
  } else {
    col = sky;
  }

  return col;
}

// -----------------------------==>> SUNSET <<==--------------------------------

void mainImage(out vec4 fragColor, vec2 p, vec2 q) {
/* TODO:
    1. (x) Lowpass filter the distance fields and reduce size
    2. (x) Improve effect 5 (impulse_main 2)    
    3. (x) Find music
    4. Convert to executable
*/
  p.x *= resolution.x/resolution.y;

  vec3 col = vec3(0.0);

  switch(PERIOD) {
  case 0: col = impulse_main(p, q); break;
  case 1: col = mandala_main(p, q); break;
  case 2: col = mandelbone_main(p, q); break;
  case 3: col = infcw_main(p, q); break;
  case 4: col = mandelbone_main(p, q); break;
  case 5: col = impulse_main(p, q); break;
  case 6: col = mandelbone_main(p, q); break;
  case 7: col = mandala_main(p, q); break;
  case 8: col = mandelbone_main(p, q); break;
  case 9: col = sunset_main(p, q); break;
  }
//  col = impulse_main(p, q);

  col = fade(col, p);
  fragColor = vec4(col, 1.0);
}