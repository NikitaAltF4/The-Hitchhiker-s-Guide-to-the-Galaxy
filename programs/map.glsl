vec2 map(vec3 p)
{

    //Плоскость
    float planeteDist = fPlane(p, vec3(0,1,0), 1.0);
    float PlaneID =2.0;
    vec2 plane = vec2(planeteDist,PlaneID);
    //Постомент0
    float boxDist0 = fBox(p, vec3(10,3,10));
    boxDist0+= bumpMapping(u_texture3, p,p+postomBampFactor,boxDist0,postomBampFactor,postomScale);
    boxDist0+=postomBampFactor;
    float boxID0=3.0;
    vec2 box0 = vec2(boxDist0,boxID0);
    //Постомент1
    vec3 pc=p;
    pc.y -= 4;
    float boxDist1 = fBox(pc.xyz, vec3(6,1.5,6));
    boxDist1+= bumpMapping(u_texture3, pc,pc+postomBampFactor,boxDist1,postomBampFactor,postomScale);
    boxDist1+=postomBampFactor;
    float boxID1=3.0;
    vec2 box1 = vec2(boxDist1,boxID1);
    //Постомент2(скуруглённый)
    vec3 pr=p;
    pr.y -= 5.8 ;
    float boxDist2 = sdRoundBox(pr.xyz, vec3(4,1 ,4),1 );
    boxDist2+= bumpMapping(u_texture1, pr,pr+handBampFactor,boxDist2,handBampFactor,handScale);
    boxDist2+=handBampFactor;
    float boxID2 = 5.0;
    vec2 box2 = vec2(boxDist2,boxID2);
    //Туловище(низ)
    vec3 ps0=p;
    ps0.y -= 6.3 ;
    ps0.x += 1 ;
    float sphereDist0 = fSphere(ps0.xyz, 2.5);
    boxDist0+= bumpMapping(u_texture1, ps0,ps0+handBampFactor,boxDist0,handBampFactor,handScale);
    boxDist0+=handBampFactor;
    float sphereID0 = 5.0;
    vec2 sphere0 = vec2(sphereDist0,sphereID0);
    //Туловище(середина)
    vec3 ps1=p;
    ps1.y -= 8.8 ;
    ps1.x += 1.7;
    float sphereDist1 = fSphere(ps1.xyz, 1.5);
    sphereDist1+= bumpMapping(u_texture1, ps1,ps1+handBampFactor,sphereDist1,handBampFactor,handScale);
    sphereDist1+=handBampFactor;
    float sphereID1 = 4.0;
    vec2 sphere1 = vec2(sphereDist1,sphereID1);
    //Туловище(Верх)
    vec3 ps2=p;
    ps2.y -= 10 ;
    ps2.x += 1.7;
    float sphereDist2 = fSphere(ps2.xyz, 0.8);
    sphereDist2+= bumpMapping(u_texture1, ps2,ps2+handBampFactor,sphereDist2,handBampFactor,handScale);
    sphereDist2+=handBampFactor;
    float sphereID2 = 5.0;
    vec2 sphere2 = vec2(sphereDist2,sphereID2);
    //Голова
    vec3 pbox0=p;
    pbox0.y -= 13.4;
    pbox0.x -= 0.7;
    rotateZ(pbox0.xyz, -0.2);
    rotateX(pbox0.xyz, -0.1);
    pbox0.x -= 0.7;
    float boxDist3 = sdRoundBox(pbox0.xyz, vec3(3.5 ,3 ,3.5), 0.6 );
    boxDist3+= bumpMapping(u_texture1, pbox0,pbox0+handBampFactor,boxDist3,handBampFactor,handScale);
    boxDist3+=handBampFactor;
    float boxID3 = 5.0;
    vec2 box3 = vec2(boxDist3,boxID3);
    //Рука правая(предплечье)
    vec3 pCone0=p;
    pCone0.y -= 9.5;
    pCone0.x += 1.5;
    pCone0.z -= 1.3;
    rotateZ(pCone0.xyz, -2.35);
    rotateX(pCone0.xyz, 0.4);
    float ConeDist0 = sdRoundCone(pCone0.xyz, 0.35, 0.2, 4);
    ConeDist0+= bumpMapping(u_texture1, pCone0,pCone0+handBampFactor,ConeDist0,handBampFactor,handScale);
    ConeDist0+=handBampFactor;
    float ConeID0 = 4.0;
    vec2 Cone0 = vec2(ConeDist0,ConeID0);
    //Рука левая( предплечье)
    vec3 pCone1=p;
    pCone1.y -= 9.5;
    pCone1.x += 1.5;
    pCone1.z -= -1.3;
    rotateZ(pCone1.xyz, -2.35);
    rotateX(pCone1.xyz, -0.4);
    float ConeDist1 = sdRoundCone(pCone1.xyz, 0.35, 0.2, 4);
    ConeDist1+= bumpMapping(u_texture1, pCone1,pCone1+handBampFactor,ConeDist1,handBampFactor,handScale);
    ConeDist1+=handBampFactor;
    float ConeID1 = 4.0;
    vec2 Cone1 = vec2(ConeDist1,ConeID1);
    //Рука правая(локоть)
    vec3 pCone01=p;
    pCone01.y -= 9.9;
    pCone01.x -= 1.9;
    pCone01.z -= 3.6;
    rotateZ(pCone01.xyz, 2.9);
    rotateX(pCone01.xyz, -0.2);

    float ConeDist01 = sdRoundCone(pCone01.xyz, 0.35, 0.2, 3.5);
    ConeDist01+= bumpMapping(u_texture1, pCone01,pCone01+handBampFactor,ConeDist01,handBampFactor,handScale);
    ConeDist01+=handBampFactor;
    float ConeID01 = 4.0;
    vec2 Cone01 = vec2(ConeDist01,ConeID01);
    //Рука левая(локоть)
    vec3 pCone11=p;
    pCone11.y -= 9.3;
    pCone11.x -= 1.9;
    pCone11.z += 2.9;
    rotateZ(pCone11.xyz, 2.9);
    rotateX(pCone11.xyz, 0.0);
    float ConeDist11 = sdRoundCone(pCone11.xyz, 0.35, 0.2, 2.7);
    ConeDist11+= bumpMapping(u_texture1, pCone11,pCone11+handBampFactor,ConeDist11,handBampFactor,handScale);
    ConeDist11+=handBampFactor;
    float ConeID11 = 4.0;
    vec2 Cone11 = vec2(ConeDist11,ConeID11);
    //Кисть левая
    vec3 wrist0=p;
    wrist0.y -=10.2;
    wrist0.x -= 1.9;
    wrist0.z += 3;
    rotateZ(wrist0.xyz, -0.2);
    rotateX(wrist0.xyz, -0.3);
    float wristDist0 = sdRoundBox(wrist0.xyz, vec3(1 ,1 ,0.5), 0.6 );
    wristDist0+= bumpMapping(u_texture1, wrist0,wrist0+handBampFactor,wristDist0,handBampFactor,palmScale);
    wristDist0+=handBampFactor;
    float wristID0 = 6.0;
    vec2 Wrist0 = vec2(wristDist0,wristID0);
    //Ладонь левая
    vec3 wrist01=p;
    wrist01.y -=9.8;
    wrist01.x -= 1.8;
    wrist01.z += 2.3;
    rotateZ(wrist01.xyz, -0.2);
    rotateX(wrist01.xyz, 1.5);
    float wristDist01 = sdRoundBox(wrist01.xyz, vec3(0.85 ,1 ,0.3), 0.3 );\
    wristDist01+= bumpMapping(u_texture1, wrist01,wrist01+handBampFactor,wristDist01,handBampFactor,palmScale);
    wristDist01+=handBampFactor;
    float wristID01 = 6.0;
    vec2 Wrist01 = vec2(wristDist01,wristID01);
    //Кисть правая
    vec3 wrist1=p;
    wrist1.y -= 10.8;
    wrist1.x -= 1.9;
    wrist1.z -= 3.6;
    rotateZ(wrist1.xyz, -0.2);
    rotateX(wrist1.xyz, -0.1);
    float wristDist1 = sdRoundBox(wrist1.xyz, vec3(1 ,1 ,0.5), 0.6 );
    wristDist1+= bumpMapping(u_texture1, wrist1,wrist1+handBampFactor,wristDist1,handBampFactor,palmScale);
    wristDist1+=handBampFactor;
    float wristID1 = 6.0;
    vec2 Wrist1 = vec2(wristDist1,wristID1);
    //Ладонь правая
    vec3 wrist11=p;
    wrist11.y -=10.2;
    wrist11.x -= 1.8;
    wrist11.z -= 3,6;
    rotateZ(wrist11.xyz, -0.2);
    rotateX(wrist11.xyz, 1.5);
    float wristDist11 = sdRoundBox(wrist11.xyz, vec3(0.85 ,1 ,0.3), 0.3 );
    wristDist11+= bumpMapping(u_texture1, wrist11,wrist11+handBampFactor,wristDist11,handBampFactor,palmScale);
    wristDist11+=handBampFactor;
    float wristID11 = 6.0;
    vec2 Wrist11 = vec2(wristDist11,wristID11);
    //"Рот"
    vec3 pbox4=p;
    pbox4.y -= 10.5;
    pbox4.x -= 4;
    pbox4.z += 0.3;
    rotateZ( pbox4.xyz, -0.2);
    rotateX( pbox4.xyz, -0.1);
    float boxDist4 = fBox(pbox4.xyz, vec3(0.4,0.05,2.2));
    float boxID4=3.0;
    vec2 box4 = vec2(boxDist4,boxID4);
    //глаз
    vec3 psphere=p;
    psphere.y -= 10.8 ;
    psphere.x -= 4.3 ;
    psphere.z -= 2.5 ;
    float sphereDisteye = fSphere(psphere.xyz, 0.3);
    float sphereIDeye= 1.0;
    vec2 sphereeye = vec2(sphereDisteye,sphereIDeye);
    //Горы

    vec3 pPyramid=p;
    pPyramid.y += 1 ;
    pPyramid.x -= 0 ;
    pPyramid.z -= 0;
    pMirrorOctant(pPyramid.xz, vec2(33,33));
    pMod1(pPyramid.z, 20);
    float pyramidDist = sdPyramid(pPyramid.xyz, 7, 10);
    float pyramidID= 1.0;
    vec2 pyramid = vec2(pyramidDist,pyramidID);
    //Деревья
    vec3 pTree1=p;
    pTree1.y += 1;
    pTree1.x += 0;
    pTree1.z -= 0;
    pMirrorOctant(pTree1.xz, vec2(16,16));
    pMod1(pTree1.z, 6);
    pModInterval1(pTree1.x, 3, 0, 3);
    float TreeDist1 = sdRoundCone(pTree1.xyz, 0.35, 0.2, 2.5);
    float TreeID1 = 7.0;
    vec2 Tree1 = vec2(TreeDist1,TreeID1);
    //---------------------------------------------------------
    vec3 pTreeSphere1=p;
    pTreeSphere1.y -= 2.5 ;
    pTreeSphere1.x += 0;
    pTreeSphere1.z += 0;
    pMirrorOctant(pTreeSphere1.xz, vec2(16,16));
    pMod1(pTreeSphere1.z, 6);
    pModInterval1(pTreeSphere1.x, 3, 0, 2);
    float TreeSphereDist1 = fSphere(pTreeSphere1.xyz, 1.1+fDisplace(pTreeSphere1.xyz));//
    float TreeSphereID1 = 8.0;
    vec2 TreeSphere1 = vec2(TreeSphereDist1,TreeSphereID1);
     //---------------------------------------------------------
    vec3 pTreeSphere2=p;
    pTreeSphere2.y -= 1.5 ;
    pTreeSphere2.x -= 0;
    pTreeSphere2.z -= 0.3;
    pMirrorOctant(pTreeSphere2.xz, vec2(16,16));
    pMod1(pTreeSphere2.z, 6.1);
    pModInterval1(pTreeSphere2.x, 3, 0, 3);
    float TreeSphereDist2 = fSphere(pTreeSphere2.xyz, 0.9+fDisplace(pTreeSphere2.xyz));//
    float TreeSphereID2 = 8.0;
    vec2 TreeSphere2 = vec2(TreeSphereDist2,TreeSphereID2);
    //---------------------------------------------------------
    vec3 pTreeSphere3=p;
    pTreeSphere3.y -= 1.5 ;
    pTreeSphere3.x += 0;
    pTreeSphere3.z += 0.3;
    pMirrorOctant(pTreeSphere3.xz, vec2(16,16));
    pMod1(pTreeSphere3.z, 6.1);
    pModInterval1(pTreeSphere3.x, 3, 0, 3);
    float TreeSphereDist3 = fSphere(pTreeSphere3.xyz, 0.9+fDisplace(pTreeSphere3.xyz));//
    float TreeSphereID3 = 8.0;
    vec2 TreeSphere3 = vec2(TreeSphereDist3,TreeSphereID3);
    //---------------------------------------------------------
    vec3 pTreeSphere4=p;
    pTreeSphere4.y -= 2,7 ;
    pTreeSphere4.x += 0;
    pTreeSphere4.z += 0.3;
    pMirrorOctant(pTreeSphere4.xz, vec2(16,16));
    pMod1(pTreeSphere4.z, 6.1);
    pModInterval1(pTreeSphere4.x, 3, 0, 3);
    float TreeSphereDist4 = fSphere(pTreeSphere4.xyz, 0.9+fDisplace(pTreeSphere4.xyz));//
    float TreeSphereID4 = 8.0;
    vec2 TreeSphere4 = vec2(TreeSphereDist4,TreeSphereID4);
    //Облака-----------------------------------------------------------------------------------------------------------------
    rotateZ( p, -0.2);
    rotateX( p, -0.1);
    float lightBoxDist = boxSDF(p - lightPos2, lightSize2 / 2.0);
    vec2 lightBox = vec2(lightBoxDist, 9.0);
    //---------------------------------------------------------

    //Результат
    vec2 res;
    res= fOpUnionID(sphere2,box3);
    res= fOpUnionID(res,sphereeye);
    res= fOpDifferenceID(res,box4);
    res= fOpUnionID(res,Wrist11);
    res= fOpUnionID(res,Wrist1);
    res= fOpUnionID(res,Wrist01);
    res= fOpUnionChamferID(res,Wrist0, 0.2);
    res= fOpUnionChamferID(res,sphere1, 0.2);
    res= fOpUnionChamferID(res,Cone0, 0.2);
    res= fOpUnionChamferID(res,Cone1, 0.2);
    res= fOpUnionChamferID(res,Cone01, 0.09);
    res= fOpUnionChamferID(res,Cone11, 0.09);
    res= fOpUnionID(res, sphere0);
    res= fOpUnionID(res,box2);
    res = fOpUnionID(res, box1);
    res = fOpUnionStairsID(box0, res, 2.5, 10);
    res = fOpUnionStairsID(res, plane, 5, 25);
    res= fOpUnionID(res,pyramid);
    res= fOpUnionChamferID(res,Tree1, 0.5);

    res=fOpUnionID(res,TreeSphere1);
    res=fOpUnionID(res,TreeSphere2);
    res=fOpUnionID(res,TreeSphere3);
    res=fOpUnionID(res,TreeSphere4);
    res=fOpUnionID(res, lightBox);

    return res;
}