precision mediump float;

#if defined(SCREEN_LOADER)
in vec2 p;
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

layout (location=0) uniform float iTime;
layout (location=1) uniform vec2 iResolution;

layout (location=2) uniform sampler2D iChannel0;
layout (location=3) uniform sampler2D iChannel1;

layout (location=10) uniform int iPeriod;
layout (location=11) uniform float fTimeInPeriod;

void mainImage(out vec4, in vec2);
void main(void)
{
#if defined(SCREEN_LOADER)
  mainImage(fragColor,p);
#else
  mainImage(fragColor,inData.v_texcoord*2.0 - 1);
#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// TODO:

// 2. Remove black dot artifacts in jungle section
// 4. Find bug in voronoi pattern on lonely mountain
// 5. Improve skybix

#define PI  3.141592654
#define TAU (2.0*PI)

#define TOLERANCE       0.001
#define END_STEP_FACTOR 3
#define MAX_ITER        75
#define MIN_DISTANCE    0.1
#define MAX_DISTANCE    30
#define GLOBAL_SCALE    1.2

const float seaScale = 55.0;

#define INTERVAL 36.0

#if defined(SCREEN_LOADER)
#define PERIOD iPeriod
#define TIMEINPERIOD fTimeInPeriod
#else
#define PERIOD int(iTime/INTERVAL)
#define TIMEINPERIOD mod(iTime, INTERVAL)
#endif

float rand(in vec2 co)
{
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 hash(in vec2 p)
{
  p=vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
  return fract(sin(p)*18.5453);
}

void rot(inout vec2 p, in float a)
{
  float c = cos(a);
  float s = sin(a);

  p = vec2(p.x*c + p.y*s, -p.x*s + p.y*c);
}

mat2 mrot(in float a)
{
  float c = cos(a);
  float s = sin(a);
  return mat2(c, s, -s, c);
}

const float gravity = 1.0;
const float waterTension = 0.01;

vec2 wave(in float t, in float a, in float w, in float p)
{
  float x = t;
  float y = a*sin(t*w + p);
  return vec2(x, y);
}

vec2 dwave(in float t, in float a, in float w, in float p)
{
  float dx = 1.0;
  float dy = a*w*cos(t*w + p);
  return vec2(dx, dy);
}

#define AMPMOD tanh(0.02*k*h)

vec2 gravityWave(in float t, in float a, in float k, in float h)
{
  float w = sqrt(gravity*k);
  return wave(t, a*AMPMOD, k, w*iTime);
}

vec2 gravityWaveD(in float t, in float a, in float k, in float h)
{
  float w = sqrt(gravity*k);
  return dwave(t, a*AMPMOD, k, w*iTime);
}

vec2 capillaryWave(in float t, in float a, in float k, in float h)
{
  float w = sqrt((gravity*k + waterTension*k*k*k));
  return wave(t, a*AMPMOD, k, w*iTime);
}

vec2 capillaryWaveD(in float t, in float a, in float k, in float h)
{
  float w = sqrt((gravity*k + waterTension*k*k*k));
  return dwave(t, a*AMPMOD, k, w*iTime);
}

vec4 sea(in vec2 p, in float h, in float ia)
{
  float y = 0.0;
  vec3 d = vec3(0.0);

  float k = 1.5;
  float kk = 1.2;
  float a = ia*0.2;
  float aa = 1.0/(kk*kk);

  const float scale = seaScale;

  p *= scale;

  float angle = 0.0;

  for (int i = 0; i < 4; ++i)
  {
    mat2 fr = mrot(angle);
    mat2 rr = transpose(fr);
    vec2 pp = fr*p;
    y += gravityWave(pp.y + float(i), a, k, h).y;
    vec2 dw = gravityWaveD(pp.y + float(i), a, k, h);

    vec2 d2 = vec2(0.0, dw.x);
    vec2 rd2 = rr*d2;

    d += vec3(rd2.x, dw.y, rd2.y);

    angle += float(i);
    k *= kk;
    a *= aa;
  }

  for (int i = 4; i < 8; ++i)
  {
    mat2 fr = mrot(angle);
    mat2 rr = transpose(fr);
    vec2 pp = fr*p;
    y += capillaryWave(pp.y + float(i), a, k, h).y;
    vec2 dw = capillaryWaveD(pp.y + float(i), a, k, h);

    vec2 d2 = vec2(0.0, dw.x);
    vec2 rd2 = rr*d2;

    d += vec3(rd2.x, dw.y, rd2.y);

    angle += float(i);
    k *= kk;
    a *= aa;
  }

  vec3 t = normalize(d);
  vec3 nxz = normalize(vec3(t.z, 0.0, -t.x));
  vec3 nor = cross(t, nxz);

  return vec4(y/scale, nor);
}

float heightFactor(in vec2 p)
{
  switch(PERIOD)
  {
  case 0:
  case 1:
  case 5:
    return 0.3;
  case 2:
  case 7:
    return (0.75 + 0.25*cos(0.025*(65 + 35*cos(0.025*p.y))*p.x + 10*cos(0.025*2*p.y)));
  case 3:
  case 6:
  case 8:
    return 1.0/(1.0 - 0.2 + length(0.3*(p - vec2(8 + 0.3, 8 + 407.0)).xy));
  case 4:
  case 9:
    float hd = (p.y - 100)*0.02;
    return 1.05*(0.75 + 0.25*cos(0.025*(65 + 35*cos(0.025*p.y))*p.x + 10*cos(0.025*2*p.y)))*(exp(-hd*hd));
  default:
    return 1.0;
  }
}

float hiTerrain(in vec2 p)
{
  vec2 pp = p;
  p *= 0.025;
  vec4 t = vec4(0);
  float s=.5;

  t = texture(iChannel0,p*s)/(s += s);

  for (int j = 1; j < 10; ++j)
  {
    t += texture(iChannel0,p*s)/(s += GLOBAL_SCALE*s);
  }

  return t.x*heightFactor(pp);
}

float loTerrain(in vec2 p)
{
  vec2 pp = p;
  p *= 0.025;
  vec4 t = vec4(0);
  float s=.5;

  t = texture(iChannel0,p*s)/(s += s);

  for (int j = 1; j < 6; ++j)
  {
    t += texture(iChannel0,p*s)/(s += GLOBAL_SCALE*s);
  }

  return t.x*heightFactor(pp);
}

float superLoTerrain(in vec2 p)
{
  vec2 pp = p;
  p *= 0.025;
  vec4 t = vec4(0);
  float s=.5;

  // A bug that superLo precision is computed differently than
  // hi & lo ended up looking nice
  t = texture(iChannel0,p*s)/(s += GLOBAL_SCALE*s);

  for (int j = 1; j < 3; ++j)
  {
    t += texture(iChannel0,p*s)/(s += s);
  }

  return t.x*heightFactor(pp);
}

vec3 getHiNormal(in vec2 p, in float d)
{
  vec2 eps = vec2(mix(0.0008, 0.001*d, smoothstep(3.0, 9.0, d)), 0);
  float dx = hiTerrain(p - eps) - hiTerrain(p + eps);
  float dy = 2.0f*eps.x;
  float dz = hiTerrain(p - eps.yx) - hiTerrain(p + eps.yx);
  return normalize(vec3(dx, dy, dz));
}

vec3 getLoNormal(in vec2 p, in float d)
{
  vec2 eps = vec2(0.004*d, 0);
  float dx = loTerrain(p - eps) - loTerrain(p + eps);
  float dy = 2.0f*eps.x;
  float dz = loTerrain(p - eps.yx) - loTerrain(p + eps.yx);
  return normalize(vec3(dx, dy, dz));
}


const float step_factors[END_STEP_FACTOR] = float[END_STEP_FACTOR](0.75, 0.25, 0.25/4);

float march(in vec3 ro, in vec3 rd, out int max_iter)
{
  float dt = 0.1;
  float d = mix(MIN_DISTANCE, 2.0*MIN_DISTANCE, rand(ro.xy + rd.xy));

  int sfi = 0;
  float lh = 0.0;
  float ly = 0.0;

  for (int i = 0; i < MAX_ITER; ++i)
  {
    vec3 p = ro + d*rd;
    float h = loTerrain(p.xz);

    if (d > MAX_DISTANCE)
    {
      max_iter = i;
      return MAX_DISTANCE;
    }

    float hd = p.y - h;

    if (hd < TOLERANCE)
    {
      ++sfi;
      if (sfi == END_STEP_FACTOR || hd > -TOLERANCE)
      {
        max_iter = i;
        return d - dt + dt*(lh-ly)/(p.y-ly-h+lh);
      }
      else
      {
        d -= 1.5*dt;
      }
    }

    lh = h;
    ly = p.y;
    dt = max(step_factors[sfi]*hd, TOLERANCE) + d*0.001;
    d += dt;
  }

  max_iter = MAX_ITER;
  return MAX_DISTANCE;
}

float shadow(in vec3 ro, in vec3 rd, in float ll, in float mint, in float k)
{
  float t = mint;
  for (int i=0; i<24; ++i)
  {
    vec3 p = ro + t*rd;
    float h = loTerrain(p.xz);
    float d = (p.y - h);
    if (d < TOLERANCE) return 0.0;
    if (t > ll) return 1.0;
    t += max(0.1, 0.25*h);
  }
  return 1.0;
}

const vec3 skyColLo = vec3(0.6, 0.35, 0.3);
const vec3 skyColHi = vec3(0., 0.6, 1.0);
const vec3 sunCol1  = vec3(1.0,0.5,0.4);
const vec3 sunCol2  = vec3(1.0,0.8,0.7);
const vec3 skyCol3  = pow(sunCol2, vec3(0.25));
const vec3 sunDir   = normalize(vec3(-1.0, 0., -1.0));
const vec3 seaCol1  = 0.8*vec3(0.1,0.2,0.2);

vec3 sunDirection(in float timeOfDay)
{
  vec3 sunDir = sunDir;
  float angle = timeOfDay*TAU;
  rot(sunDir.xy, sin(angle));
  rot(sunDir.xz, angle-0.5);
  return sunDir;
}

vec3 skyCol(in float sunf)
{
  return mix(skyColLo, skyColHi, clamp(sunf, 0.0, 1.0));
}

vec3 ambient(in float sunf, in vec3 sunDir, vec3 rd)
{
  return skyCol(sunf)*mix(0.5, 0.2, pow(max(dot(sunDir, rd), 0), 2));
}

vec3 skyColor(in float sunf, in vec3 sunDir, in vec3 rd)
{
  float skyf = atan(rd.y, length(rd.xz))*2.0/PI;

  vec3 skyCol1 = skyCol(sunf);
  vec3 skyCol2 = skyCol(sunf);

  vec3 starDir = sunDir;
  rot(starDir.xz, 0.2);
  rot(starDir.xy, 0.2);

  float sunDot = max(dot(rd, sunDir), 0.0);
  float starDot = max(dot(rd, starDir), 0.0);

  vec3 final = vec3(0.0);

  final += mix(mix(skyCol1, skyCol2, max(0.0, skyf)), skyCol3, clamp(-skyf*2.0, 0.0, 1.0));

  final += 1.0*sunCol1*pow(sunDot, mix(30.0, 300.0, sunf));
  final += 80.0*sunCol2*pow(sunDot, mix(400.0, 4000.0, sunf));

  final += 2.5*(abs(starDot) > 0.999999 ? 1.0 : 0.0) ;

  return final;
}

vec4 voronoi(in vec2 x)
{
  vec2 n = floor(x);
  vec2 f = fract(x);

  vec4 m = vec4(8.0);
  for(int j=-1; j<=1; j++)
  for(int i=-1; i<=1; i++)
  {
    vec2  g = vec2(float(i), float(j));
    vec2  o = hash(n + g);
    vec2  r = g - f + o;
    float d = dot(r, r);
    if(d<m.x)
    {
      m = vec4(d, o.x + o.y, r);
    }
  }

  return vec4(sqrt(m.x), m.yzw);
}

vec3 getColor(in float timeOfDay, in float seaHeight, in float fogHeight_, in vec3 ro, in vec3 rd)
{
  const vec3  mountainColor   = vec3(0.68, 0.4, 0.3);
  const vec3  sandColor       = sqrt(mountainColor);
  const float snowHeight      = 0.9;
  const float treeHeight      = 0.8;

  int max_iter = 0;
  float d = march(ro, rd, max_iter);
  vec3 p = ro + d*rd;

  vec3 sunDir = sunDirection(timeOfDay);
  float sunf = atan(sunDir.y, length(sunDir.xz))*2.0/PI;
  float sunf2 = sunf*sunf;

  float fogHeight = mix(fogHeight_, 0.5*fogHeight_, sunf2);

  vec3 skyCol = skyColor(sunf, sunDir, rd);
  float ired = float(max_iter)/float(MAX_ITER);
  vec3 col = vec3(0);


  float dsea = (seaHeight - ro.y)/rd.y;

  vec3 amb = ambient(sunf, sunDir, rd);

  if (d > dsea && dsea > 0.0)
  {
    // SEA

    vec3 psea = ro + dsea*rd;

    float height = loTerrain(psea.xz);
    float depth = max(0.0, seaHeight - height);

    vec3 loNormal = getLoNormal(psea.xz, dsea);
    float flatness = dot(loNormal, vec3(0.0, 1.0, 0.0));
    float ff = abs(dot(rd, vec3(0.0, 1.0, 0.0)));

    float dseaf = dsea/MAX_DISTANCE;
    float dseafs = sqrt(dseaf);
    vec4 s = sea(psea.xz, seaScale*depth, exp(-10*dseaf*dseaf));
    float h = s.x;
//    vec3 nor = mix(s.yzw, vec3(0.0, 1.0, 0.0), mix(0.0, 1.0, dseafs));
    vec3 nor = s.yzw;

    float mint = mix(0.05, 0.1, rand(psea.xy));
    float shade = shadow(psea + vec3(0.0, h, 0.0), sunDir, 4.0, mint, 1.0);
    vec3 shd = mix(mix(amb, vec3(1.0), shade), vec3(1.0), dseafs);

    float fogHeight = (1.0 - shade*sunf2)*(fogHeight + 0.15*flatness - ff*(3*depth*flatness - 0.5*depth));
    float dfog = (fogHeight - ro.y)/rd.y;
    float fogf = dsea > dfog && dfog > 0 ? 1.0 - exp(-1.0*(dsea - dfog)) : 0.0;

    float fre = clamp(1.0 - dot(-nor,rd), 0.0, 1.0);
    fre = pow(fre, 3.0);
    float dif = max(dot(nor,sunDir), 0.0);

    vec3 refl = skyColor(sunf, sunDir, reflect(rd, nor));
    vec3 mat = skyCol*seaCol1 + sunCol1*dif*seaCol1;

    vec3 seaColor = mix(mat, mix(refl, mat, 0.75), fre*shade);
    vec3 bottomCol = max(0.5, dif)*skyCol*sandColor;
    seaColor = mix(bottomCol, seaColor, 1.0 - exp(-25*(d - dsea)));
    seaColor += mix(0.4*bottomCol, vec3(0.0), clamp(pow(depth*11.0, 2.0), 0.0, 1.0));

    col = mix(mix(shd*seaColor, skyCol, fogf), skyCol, dseaf*dseafs);
  }
  else if (d < MAX_DISTANCE)
  {
    // GROUND

    float bandings = mix(50.0, 100.0, 0.5 + 0.5*sin(length(p.y)*10));
    float bandingo = sin(length(p.xz)*3);
    float bandingf = pow(0.5 + 0.5*sin(p.y*bandings + bandingo), .25);
    float banding = mix(0.75, 1.0, bandingf);
    vec3 mountainColor = mountainColor*banding;

    vec3 hiNormal = getHiNormal(p.xz, d);
    vec3 loNormal = getLoNormal(p.xz, d);
    vec3 normal   = hiNormal;

    float flatness = dot(loNormal, vec3(0.0, 1.0, 0.0));
    float sflatness = sqrt(flatness);

    float shade = shadow(p, sunDir, 4.0, 0.05, 1.0);

    float fogHeight = (1.0 - shade*sunf2)*(fogHeight + 0.15*flatness);
    float dfog = (fogHeight - ro.y)/rd.y;
    float fogf = d > dfog && dfog > 0 ? 1.0 - exp(-1.0*(d - dfog)) : 0.0;

    float height1 = hiTerrain(p.xz);
    float height2 = superLoTerrain(p.xz);

    float heightRatioPower = 7.0;

    vec3 surfaceColor = mountainColor;

    vec3 spec = vec3(0.0);

    if (p.y > (snowHeight + 0.10*sin(0.1*length(p.xz)))/sflatness)
    {
      spec = vec3(0.5);
      normal = loNormal;
      heightRatioPower = 4.0;
      surfaceColor = vec3(1.1);
    }
    else if (p.y < seaHeight + 0.015*treeHeight*sflatness)
    {
      normal = loNormal;
      heightRatioPower = 7.0;
      surfaceColor = sandColor;
    }
    else if (p.y < treeHeight*sflatness)
    {
      vec4 t  = voronoi(p.xz*100.0);
      vec3 no = vec3(t.z, 0.0, t.w)*3*(1.0 - smoothstep(0.0, 9.0, d));
      normal = normalize(loNormal + -no);
      heightRatioPower = 5.0;
      surfaceColor = vec3(pow(1.0 - t.x, 0.5))*vec3(0.25, 0.3, 0.15)*vec3(max(1.0, 1.5*t.y), 1.0, 1.0);
    }
    else
    {
      heightRatioPower = 7.0;
      surfaceColor = mountainColor;
    }

    heightRatioPower *= clamp(0.6 + 0.4*abs(timeOfDay - 0.25), 0.0, 1.0);

    float heightRatio = pow(height1/height2, heightRatioPower);

    float dif = shade*max(0, dot(sunDir, normal));
    vec3 shd = mix(amb, vec3(1.0), heightRatio*dif); // sunCol1?

    vec3 reflectedSky = spec*skyColor(sunf, sunDir, reflect(rd, normal));

    col = mix(mix(shd*surfaceColor + reflectedSky, skyCol, fogf), skyCol, pow(d/MAX_DISTANCE, 1.5));
  }
  else
  {
    // SKY
    col = skyCol;
  }

  return col;
}

const vec3 PosOrigin = vec3(8,0,8);

const float xOffset = 5*PI;

float sech(in float t)
{
  return 1.0/cosh(t);
}

vec3 getIslandHopperPos(in float timeInPeriod)
{
  const float C = xOffset;
  float t = timeInPeriod;
  float x = (C - 10*cos(0.025*2*t))/(0.025*(65 + 35*cos(0.025*t)));
  float y = 1.0;
  float z = t;
  return vec3(x, y, z);
}

vec3 getIslandHopperPosD(in float timeInPeriod)
{
  const float C = xOffset;
  float t = timeInPeriod;
  float dx = (sin(0.025*t)*(1.4*C - 14.*cos(0.05*t)) + sin(0.05*t)*(28*cos(0.025*t) + 52))/pow(7*cos(0.025*t) + 13, 2.0);
  float dy = 0.0;
  float dz = 1.0;
  return vec3(dx, dy, dz);
}

vec3 getIslandHopperPosDD(in float timeInPeriod)
{
  const float C = xOffset;
  float t = timeInPeriod;
  float ddx = (0.025*cos(0.025*t)*(1.4*C - 14*cos(0.05*t)) + 0.05*(28*cos(0.025*t) + 52)*cos(0.05*t))/pow(7*cos(0.025*t) + 13, 2.0) + (0.35*sin(0.025*t)*(sin(0.025*t)*(1.4*C - 14*cos(0.05*t)) + sin(0.05*t)*(28*cos(0.025*t) + 52)))/pow(7*cos(0.025*t) + 13, 3.0);
  float ddy = 0;
  float ddz = 0.0;
  return 12*vec3(ddx, ddy, ddz);
}

const vec3 centerOfLonelyMountain = vec3(0.0, 1.0 , 407.0);

vec3 getLonelyMountainPos(in float timeInPeriod)
{
  float t = (timeInPeriod - 4)*0.05;
  const float w = 4*log(2.0);
  float x = -2.6 + -4*(exp(-w*(t - 1.5)*(t - 1.5)) - 1.0);
  float y = 1.1*exp(-w*(t - 1.5)*(t - 1.5)) + 0.1;
  float z = 8 - ((13.0/3.0)*t*t*t + (-39.0/2.0)*t*t + (145.0/6.0)*t);

  return PosOrigin + centerOfLonelyMountain + vec3(x, y, z);
}

vec3 getLonelyMountainPosD(in float timeInPeriod)
{
  return PosOrigin + centerOfLonelyMountain - getLonelyMountainPos(timeInPeriod);
}

vec3 getLonelyMountainPosDD(in float timeInPeriod)
{
  return vec3(0.0);
}

vec3 getCirclingLonelyMountainPos(in float timeInPeriod)
{
  float t = -(timeInPeriod - 4)*0.05 + 2;
  const float d = 12;
  float x = d*cos(t);
  float y = 3.5;
  float z = d*sin(t);

  return PosOrigin + centerOfLonelyMountain + vec3(x, y, z);
}

vec3 getCirclingLonelyMountainPosD(in float timeInPeriod)
{
  return PosOrigin + centerOfLonelyMountain - getCirclingLonelyMountainPos(timeInPeriod);
}

vec3 getCirclingLonelyMountainPosDD(in float timeInPeriod)
{
  return vec3(0.0);
}

vec3 getMistyMountainsPos(in float timeInPeriod)
{
  return PosOrigin + vec3(0.0, 1.4+0., timeInPeriod - 4);
}

vec3 getMistyMountainsPosD(in float timeInPeriod)
{
  return vec3(0.0, -0.1, 1.0);
}

vec3 getMistyMountainsPosDD(in float timeInPeriod)
{
  return vec3(0.0);
}


vec3 getSample(in vec2 p)
{
  vec3 pos   = vec3(0.0, 2.0, 0.0);
  vec3 posd  = vec3(0.0, 0.0, 1.0);
  vec3 posdd = vec3(0.0, 0.0, 0.0);

  float timeInPeriod = TIMEINPERIOD;
  float timeOfDay    = 0.25;
  float seaHeight    = 0.0;
  float fogHeight    = 0.5;
  float posTimeM     = 1.0;
  float posTimeO     = 0.0;
  vec3  posT         = vec3(0.0);
  vec3  posDT        = vec3(0.0);

  switch(PERIOD)
  {
  case 0:
    timeOfDay = -0.01*timeInPeriod/INTERVAL + 0.485;
    seaHeight = 0.55;
    posTimeM  = 2.0;
    posT      = vec3(0.0, -0.3, 0.0);
    break;
  case 1:
    seaHeight = 0.0;
    timeOfDay = 0.01*timeInPeriod/INTERVAL + 0.467;
    posTimeM  = 0.5;
    posDT     = vec3(0.0, -0.2, 0.0);
    break;
  case 2:
    seaHeight = 0.0;
    timeOfDay = 0.025*timeInPeriod/INTERVAL + 0.07;
    posT      = vec3(0.0, 0.0, 20.0);
    posDT     = vec3(0.0, -0.1, 0.0);
    break;
  case 3:
    timeOfDay = 0.23*timeInPeriod/INTERVAL + 0.02;
    seaHeight = 0.5;
    break;
  case 4:
    timeOfDay = 0.025*timeInPeriod/INTERVAL + 0.425;
    seaHeight = 0.5;
    posTimeM  = 2.0;
    posTimeO  = 30.0;
    posDT     = vec3(0.0, -0.1, 0.0);
    break;
  case 5:
    seaHeight = 0.24;
    timeOfDay = 0.01*timeInPeriod/INTERVAL + 0.467;
    posTimeM  = 0.5;
    posDT     = vec3(0.0, -0.2, 0.0);
    break;
  case 6:
    timeOfDay = 0.025*timeInPeriod/INTERVAL + 0.07;
    seaHeight = 0.5;
    fogHeight = 0.75;
    break;
  case 7:
    seaHeight = 0.5;
    timeOfDay = 0.025*timeInPeriod/INTERVAL + 0.45;
    posT      = vec3(0.0, 0.0, 90.0);
    posDT     = vec3(0.0, -0.1, 0.0);
    break;
  case 8:
    timeOfDay = 0.23*(INTERVAL + timeInPeriod)/INTERVAL + 0.02;
    seaHeight = 0.5;
    posTimeO  = INTERVAL;
    break;
  case 9:
    timeOfDay = 0.025*(INTERVAL + timeInPeriod)/INTERVAL + 0.425;
    seaHeight = 0.5;
    posTimeM  = 2.0;
    posTimeO  = 30.0 + INTERVAL;
    posDT     = vec3(0.0, -0.1, 0.0);
    break;
  default:
    break;
  }

  float posTime = timeInPeriod*posTimeM + posTimeO;

  switch(PERIOD)
  {
  case 0:
  case 1:
  case 2:
  case 5:
  case 7:
    pos   = getMistyMountainsPos(posTime);
    posd  = getMistyMountainsPosD(posTime);
    posdd = getMistyMountainsPosDD(posTime);
    break;
  case 3:
    pos   = getLonelyMountainPos(posTime);
    posd  = getLonelyMountainPosD(posTime);
    posdd = getLonelyMountainPosDD(posTime);
    break;
  case 6:
    pos   = getCirclingLonelyMountainPos(posTime);
    posd  = getCirclingLonelyMountainPosD(posTime);
    posdd = getCirclingLonelyMountainPosDD(posTime);
    break;
  case 4:
  case 9:
    pos   = getIslandHopperPos(posTime);
    posd  = getIslandHopperPosD(posTime);
    posdd = getIslandHopperPosDD(posTime);
    break;
  case 8:
    pos   = getLonelyMountainPos(posTime);
    posd  = getLonelyMountainPosD(posTime);
    posdd = getLonelyMountainPosDD(posTime);
    break;
  default:
    break;
  }

  vec3 up = vec3(0.0,1.0,0.0) + posdd ;
  vec3 ro = pos + posT;
  vec3 ww = normalize(posd + posDT);
  vec3 uu = normalize(cross(up, ww));
  vec3 vv = normalize(cross(ww, uu));
  vec3 rd = normalize(p.x*uu + p.y*vv + 2.0*ww);

  vec3 col = getColor(timeOfDay, seaHeight, fogHeight, ro, rd);

  return col;

}

vec3 saturate(in vec3 col)
{
  return clamp(col, vec3(0.0), vec3(1.0));
}

void mainImage(out vec4 fragColor, in vec2 p)
{
  p.x *= iResolution.x/iResolution.y;

  vec3 col = getSample(p);

  col = saturate(col);

  float timeInPeriod = TIMEINPERIOD;

  float fade = clamp(timeInPeriod*0.5, 0.0, 1.0)*clamp((INTERVAL - timeInPeriod)*0.5, 0.0, 1.0);
  col = mix(vec3(0.0), col, fade*fade);

  if (PERIOD == 0)
  {
    vec2 tp = 0.5*vec2(p.x + 0.75, -p.y + 0.02) + 0.5;
    tp.x /= 1920.0/1200.0;
    float texFade = clamp((iTime - 8.0)*2.0/INTERVAL, 0.0, 1.0);
    col = mix(texture(iChannel1, tp).xyz, col, texFade);
  }

  fragColor = vec4(col, 1.0);
}
