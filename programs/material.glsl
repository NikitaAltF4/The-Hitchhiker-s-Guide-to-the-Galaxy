vec3 getMaterial(vec3 p, float id, vec3 normal) {
    vec3 m;
    switch (int(id)) {
        //Горы
        case 1:
        m = triPlanar(u_texture2, p*mountScale, normal); break;
        //Земля
        case 2:
        m =triPlanar(u_texture3, p* landScale, normal); break;
        //Постамент
        case 3:
        m = triPlanar(u_texture4, p* postomScale, normal); break;
        //Руки.
        case 4:
        m = triPlanar(u_texture1, p*handScale, normal); break;
        //Голова, подставка, основание мыслителя
        case 5:
        p.y -=13.4;
        p.x -=0.7;
        rotateZ(p, -0.2);
        rotateX(p, -0.1);
        rotateZ(normal, -0.2);
        rotateX(normal, -0.1);
        m = triPlanar(u_texture1, p*headScale, normal); break;
        //Ладони
        case 6:
        m = triPlanar(u_texture1, p*palmScale, normal); break;
        case 7:
        m = triPlanar(u_texture5, p*treeScale, normal); break;
        case 8:
        normal=abs(normal);
        normal = pow(normal, vec3(5.0));
        normal /= normal.x+normal.y+ normal.z;
        m = triPlanar(u_texture6, p*ladderScale, normal); break;
        case 9:
        m= vec3(0.0, 1.0, 0.0); break;

        default:
        m = vec3(0.4); break;
    }
    return m;
}