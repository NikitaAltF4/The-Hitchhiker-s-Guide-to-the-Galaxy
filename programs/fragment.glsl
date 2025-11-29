#version 430 core
#include hg_sdf.glsl
layout (location = 0) out vec4 fragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_scroll;
uniform float u_time;

uniform sampler2D u_texture1;
uniform sampler2D u_texture2;
uniform sampler2D u_texture3;
uniform sampler2D u_texture4;
uniform sampler2D u_texture5;
uniform sampler2D u_texture6;
uniform sampler2D u_texture7;//День
uniform sampler2D u_texture8;//Ночь

const float FOV = 1.0; //Область видемости камеры, условный угол обзора
const int MAX_STEPS = 256;// Кол-во лучей
const float MAX_DIST = 500;// Максимальная дистанция
const float EPSILON = 0.001;// Точность рассчета при приближении к поверхности


float headScale= 0.2;
float mountScale= 0.1;
float landScale=0.005;


float postomScale =0.2;
float postomBampFactor =0.01;

float handScale =0.1;
float handBampFactor =0.005;

float palmScale =0.35;
float treeScale =0.35;
float ladderScale =0.35;

// --- Параметры для управления источниками света ---
float lightIntensity1 = 1.0; // Мощность первого источника света (0.0 - выключен)
float lightIntensity2 = 0.01; // Мощность второго источника света (0.0 - выключен)

// Параметры для параллелепипеда-источника света
vec3 lightPos2 = vec3(2, 11.05, 1); // Позиция центра
vec3 lightSize2 = vec3(0.4, 0.05, 5); // Размеры (x, y, z)
// --------------------------------------------------

vec3 triPlanar(sampler2D tex, vec3 p, vec3 normal) {
    normal = abs(normal);
    normal = pow(normal, vec3(5.0));
    normal /= normal.x + normal.y + normal.z;
    return (texture(tex, p.xy * 0.5 + 0.5) * normal.z +
            texture(tex, p.xz * 0.5 + 0.5) * normal.y +
            texture(tex, p.yz * 0.5 + 0.5) * normal.x).rgb;
}

float bumpMapping(sampler2D tex, vec3 p, vec3 n, float dist, float factor, float scale) {
    float bump = 0.0;
    if (dist < 1) {
        vec3 normal = normalize(n);
        bump += factor * triPlanar(tex, (p * scale), normal).r;
    }
    return bump;
}

float fDisplace(vec3 p) {
    pR(p.yz, sin(2.0 * u_time));
    return (cos(p.x +  u_time) * sin(p.y + sin(u_time)) * cos(p.z +  u_time));
}
//Соединение
vec2 fOpUnionID(vec2 res1, vec2 res2) {
    return (res1.x < res2.x) ? res1 : res2;
}
//Плавный переход с учетом ID лесенко
vec2 fOpUnionStairsID(vec2 res1, vec2 res2, float r, float n) {
    float dist = fOpUnionStairs(res1.x, res2.x, r, n);
    return (res1.x < res2.x) ? vec2(dist, res1.y) : vec2(dist, res2.y);
}
//Плавный переход с учетом ID
vec2 fOpUnionChamferID(vec2 res1, vec2 res2, float r){
       float dist = fOpUnionChamfer(res1.x, res2.x, r);
       return (res1.x < res2.x) ? vec2(dist, res1.y) : vec2(dist, res2.y);
}
//Вычитание
vec2 fOpDifferenceID(vec2 res1, vec2 res2) {
    return (res1.x > -res2.x) ? res1 : vec2(-res2.x, res2.y);
}
float boxSDF(vec3 p, vec3 size) {
    vec3 q = abs(p) - size;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
#include map.glsl
#include material.glsl
// Функция для вычисления расстояния до параллелепипеда (box SDF)


// Функция возращает 2-ч мерный вектор для хранения в X компоненте растояние для объекта, а в Y получить ID объекта(его цвет)
vec2 rayMarch(vec3 ro, vec3 rd) {
    vec2 hit, object;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + object.x * rd;
        hit = map(p);
        object.x += hit.x;
        object.y = hit.y;
        if (abs(hit.x) < EPSILON || object.x > MAX_DIST) break;
    }
    return object;
}
//Полутени с учётом размера источника освещения
float getSoftShadow(vec3 p, vec3 lightPos, float lightIntensity) {
    if (lightIntensity <= 0.0) {
        return 0.0;
    }

    float res = 1.0;
    float dist = 0.01;
    float lightSize = 0.03;
    for (int i = 0; i < MAX_STEPS; i++) {
        float hit = map(p + lightPos * dist).x;
        res = min(res, hit / (dist * lightSize));
        dist += hit;
        if (hit < 0.0001 || dist > 60.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

float getAmbientOcclusion(vec3 p, vec3 normal) {
    float occ = 0.0;
    float weight = 1.0;
    for (int i = 0; i < 8; i++) {
        float len = 0.01 + 0.02 * float(i * i);
        float dist = map(p + normal * len).x;
        occ += (len - dist) * weight;
        weight *= 0.85;
    }
    return 1.0 - clamp(0.6 * occ, 0.0, 1.0);
}
//Для нахождение нормали нам нужен градиент поверхности
vec3 getNormal(vec3 p){
    vec2 e = vec2(EPSILON, 0.0);
     vec3 n = vec3(map(p).x) - vec3(map(p - e.xyy).x, map(p - e.yxy).x, map(p - e.yyx).x); // от точки вычитаем молое знаечение, будет второрая точка, чтобы без долгих вычислений
    return normalize(n);
}
//По закону Фонга
vec3 getLight(vec3 p, vec3 rd, float id)
{
    // --- Анимация первого источника света ---
    float dayTime = mod(u_time, 120.0);
    float dayProgress = dayTime / 120.0;

    float lightAngle = dayProgress * 3.14159265;
    vec3 lightPos1 = vec3(20.0 * cos(lightAngle), 20.0 * sin(lightAngle), -30.0);
    float lightIntensity1 = smoothstep(0.1, 0.9, sin(lightAngle));
    // --- Конец анимации ---



    // Первый источник света
    //vec3 lightPos1 = vec3(20.0, 40.0, -30.0);
    vec3 L1 = normalize(lightPos1 - p);
    vec3 N = getNormal(p);
    vec3 V = -rd;
    vec3 R1 = reflect(-L1, N);

    vec3 color = getMaterial(p, id, N);

    // Компоненты освещения для первого источника света (умножаем на lightIntensity1)
    vec3 specColor1 = vec3(0.6, 0.5, 0.4);
    vec3 specular1 = lightIntensity1 * 1.3 * specColor1 * pow(clamp(dot(R1, V), 0.0, 1.0), 10.0);
    vec3 diffuse1 = lightIntensity1 * 0.9 * color * clamp(dot(L1, N), 0.0, 1.0);
    vec3 ambient1 = lightIntensity1 * color * 0.05;
    vec3 fresnel1 = lightIntensity1 * 0.15 * color * pow(1.0 + dot(rd, N), 3.0);

    // Тени для первого источника (передаем lightIntensity1)
    float shadow1 = getSoftShadow(p + N * 0.02, normalize(lightPos1), lightIntensity1);

    // --- Обработка свечения параллелепипеда ---
    if (id == 9.0) {
        vec3 lightColor2 = vec3(0.0, 1.0, 0.0); // Цвет свечения
        //
        vec3 lightDirection = vec3(1.0, 0.0, 0.0); // Направление в локальной системе
         // Нормаль к поверхности параллелепипеда
        vec3 N = getNormal(p);
        // -----------------------------------------------------
        // --- Расчет интенсивности свечения (только в нужном направлении) ---
        float spotAngle = radians(30.0); // Угол конуса света (в градусах)
        float spotExponent = 10.0; // Концентрация света (чем больше, тем уже луч)

        vec3 L = -lightDirection; // Направление от точки к источнику света
        float angle = acos(dot(L, N)); // Угол между L и нормалью
        float intensity = smoothstep(spotAngle, spotAngle - 0.1, angle); // Плавное затухание
        intensity = pow(intensity, spotExponent); // Концентрация света

        float emissionIntensity = lightIntensity2 * intensity;
        vec3 emission = lightColor2 * emissionIntensity;
        // ----------------------------------------------------------------

        // Добавляем ambient, diffuse и specular компоненты для самого параллелепипеда
        vec3 ambient2 = lightColor2 * 0.1; // Слабое фоновое освещение
        vec3 diffuse2 = lightColor2 * 0.5 * max(0.0, dot(N, -lightDirection)); // Рассеянный свет
        vec3 specular2 = lightColor2 * 0.3 * pow(max(0.0, dot(reflect(lightDirection, N), V)), 10.0); // Зеркальный свет

    return ambient2 + diffuse2 + specular2 + emission;
    }
    // --- Конец обработки свечения ---

    // Компоненты освещения для второго источника света (умножаем на lightIntensity2)
    vec3 L2 = normalize(lightPos2 - p);
    vec3 R2 = reflect(-L2, N);
    vec3 specColor2 = vec3(0.0, 1, 0.0);
    vec3 specular2 = lightIntensity2 * 1.0 * specColor2 * pow(clamp(dot(R2, V), 0.0, 1.0), 10.0);
    vec3 diffuse2 = lightIntensity2 * 0.7 * color * clamp(dot(L2, N), 0.0, 1.0);
    vec3 ambient2 = lightIntensity2 * color * 0.03;
    vec3 fresnel2 = lightIntensity2 * 0.1 * color * pow(1.0 + dot(rd, N), 3.0);

    // Тени для второго источника (передаем lightIntensity2)
    float shadow2 = getSoftShadow(p + N * 0.02, normalize(lightPos2), lightIntensity2);

    float occ = getAmbientOcclusion(p, N);
    vec3 back = 0.05 * color * clamp(dot(N, -L1), 0.0, 1.0);

    return ((back + ambient1 + fresnel1) * occ * shadow1 + (diffuse1 * occ + specular1) * shadow1) +
           ((ambient2 + fresnel2) * shadow2 + (diffuse2 * occ + specular2) * shadow2);
}
//Камера
mat3 getCam(vec3 ro, vec3 lookAt){
    vec3 camF = normalize(vec3(lookAt - ro));
    vec3 camR = normalize(cross(vec3(0, 1, 0), camF));
    vec3 camU = cross(camF, camR);
    return mat3(camR, camU, camF);
}
//Контроль камеры
void mouseControl(inout vec3 ro) {
    vec2 m = u_mouse / u_resolution;
    pR(ro.yz, m.y * PI * 0.39 - 0.39);
    pR(ro.xz, m.x * TAU);
}

vec3 render(vec2 uv) {
    vec3 col = vec3(0);

    vec3 ro = vec3(36.0, 25.0, -36.0) / u_scroll;
    mouseControl(ro);

    vec3 lookAt = vec3(0, 1, 0);
    vec3 rd = getCam(ro, lookAt) * normalize(vec3(uv, FOV));

    // --- Смена текстур фона и тумана ---
    float dayTime = mod(u_time, 120.0);
    float dayProgress = dayTime / 120.0;

    float transitionFactor = smoothstep(0.1, 0.4, dayProgress) - smoothstep(0.6, 0.9, dayProgress);
    vec3 background = mix(texture(u_texture8, rd.xy).rgb, texture(u_texture7, rd.xy).rgb, transitionFactor);
    vec3 fogColor = mix(vec3(0.0), vec3(0.5, 0.8, 0.9), transitionFactor);

    vec2 object = rayMarch(ro, rd);

    if (object.x < MAX_DIST) {
        vec3 p = ro + object.x * rd;
        col += getLight(p, rd, object.y);
        // Туман
        col = mix(col, fogColor, 1.0 - exp(-1e-6 * object.x * object.x * object.x));
    } else {
        col += background - max(0.9 * rd.y, 0.0);
    }
    return col;
}

//Расчет координат для сглаживания
vec2 getUV(vec2 offset) {
    return (2.0 * (gl_FragCoord.xy + offset) - u_resolution.xy) / u_resolution.y;
}
//сглаживания( свизлиг, сумирющий цвет пикселя/ на чило лучей(4))
vec3 renderAAx4() {
    vec4 e = vec4(0.125, -0.125, 0.375, -0.375);
    vec3 colAA = render(getUV(e.xz)) + render(getUV(e.yw)) + render(getUV(e.wx)) + render(getUV(e.zy));
    return colAA /= 4.0;
}
vec3 renderAAx3() {
    float bxy = int(gl_FragCoord.x + gl_FragCoord.y) & 1;
    float nbxy = 1. - bxy;
    vec3 colAA = (render(getUV(vec2(0.66 * nbxy, 0.))) +
                  render(getUV(vec2(0.66 * bxy, 0.66))) +
                  render(getUV(vec2(0.33, 0.33))));
    return colAA / 3.0;
}
vec3 renderAAx2() {
    float bxy = int(gl_FragCoord.x + gl_FragCoord.y) & 1;
    float nbxy = 1. - bxy;
    vec3 colAA = (render(getUV(vec2(0.33 * nbxy, 0.))) + render(getUV(vec2(0.33 * bxy, 0.66))));
    return colAA / 2.0;
}
void main()
{
    //Номализация ситсемы координат, чтобы центр экрана отрисовки совпадал с её началом
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 color= renderAAx2();

    // Коррекция гаммы
    color = pow(color, vec3(0.4545));
    fragColor = vec4(color, 1.0);
}