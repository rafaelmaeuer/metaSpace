//@author: dottore
//@description: 2d Position Velocity Cycle texture
//@tags: particles dynamic texture 
//@credits: 

//transforms
float4x4 tW: WORLD;

//texture A: position of the last frame
texture PosQueue <string uiname="Position";>;
sampler SampQueue = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (PosQueue);          //apply a texture to the sampler
    MipFilter = none;         //sampler states
    MinFilter = none;
    MagFilter = none;
};

//texture B: value to add to curent position
texture PosVelAdd <string uiname="RG=Vel,BA=Acc Input Value";>;
sampler SampAdd = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (PosVelAdd);          //apply a texture to the sampler
    MipFilter = none;         //sampler states
    MinFilter = none;
    MagFilter = none;
};

//texture B: reset position
texture ResPos <string uiname="RG=Pos,BA=Vel Reset Value";>;
sampler SampResPos = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (ResPos);          //apply a texture to the sampler
    MipFilter = none;         //sampler states
    MinFilter = none;
    MagFilter = none;
    addressU = wrap;
};

texture Fields <string uiname="Fields Texture";>;
sampler SampFields = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Fields);          //apply a texture to the sampler
    //MipFilter = point;         //sampler states
    MinFilter = point;
    MagFilter = point;
    addressU = border;
    addressV = border;
};


float VelFactor <string uiname="Velocity Mult";>;
float4x4 FieldsTransform <string uiname="inverse (Fields transform * scale 0.5)";>;
float4x4 FieldsRotate <string uiname="Fields Rotate transform";>;
float FieldsValue;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

float2 XYres;
float emitterCount;
float emitIndex;
float emitIndexPrev;
float radius;
float force;
// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 Pos  : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;
    
    //transform position
    Out.Pos = mul(Pos,tW);
    
    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS1(vs2ps In): COLOR
{
    float4 posQueue = tex2D(SampQueue, In.TexCd);
    float4 PosVelAdd = tex2D(SampAdd, In.TexCd);    
    
    bool ResBang = 0;
    float index = In.TexCd.x*XYres.x + In.TexCd.y*XYres.x*XYres.y;       
    if(emitIndex >= emitIndexPrev)
      { ResBang = index > emitIndexPrev && index <= emitIndex;}
    else
      { ResBang = 1-(index < emitIndexPrev && index >= emitIndex); }
    
 /*   float indexU = 0;
    if(emitIndex >= emitIndexPrev)
      { indexU = (index - emitIndexPrev)/emitterCount ;}  
    else
      { indexU = 1-(index < emitIndexPrev && index >= emitIndex); }
 */   
    
    
    float4 resetPos = tex2D(SampResPos, float2(index/emitterCount,0));
    
	////// circular spread data from v4... could be pass also with a texture..
float2 p1 = ( float2(0.5000 ,  0.0000)*radius);
float2 p2 = ( float2(0.4330 ,  0.2500)*radius);
float2 p3 = ( float2(0.2500 ,  0.4330)*radius);
float2 p4 = ( float2(0.0000 ,  0.5000)*radius);
float2 p5 = ( float2(-0.2500 ,  0.4330)*radius);
float2 p6 = ( float2(-0.4330 ,  0.2500)*radius);
float2 p7 = ( float2(-0.5000 ,  0.0000)*radius);
float2 p8 = ( float2(-0.4330 ,  -0.2500)*radius);
float2 p9 = ( float2(-0.2500 ,  -0.4330)*radius);
float2 p10 = ( float2(0.0000 ,  -0.5000)*radius);
float2 p11 = ( float2(0.2500 ,  -0.4330)*radius);
float2 p12 = ( float2(0.4330 ,  -0.2500)*radius);
	
	////// add  brightness of all point arround particle position an multiply with direction from circular spread
	////  
	float2 d_1n  =  p1  * tex2Dlod(SampFields, mul(float4(posQueue.x+p1.x ,posQueue.y+p1.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p2  * tex2Dlod(SampFields, mul(float4(posQueue.x+p2.x ,posQueue.y+p2.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p3  * tex2Dlod(SampFields, mul(float4(posQueue.x+p3.x ,posQueue.y+p3.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p4  * tex2Dlod(SampFields, mul(float4(posQueue.x+p4.x ,posQueue.y+p4.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p5  * tex2Dlod(SampFields, mul(float4(posQueue.x+p5.x ,posQueue.y+p5.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p6  * tex2Dlod(SampFields, mul(float4(posQueue.x+p6.x ,posQueue.y+p6.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p7  * tex2Dlod(SampFields, mul(float4(posQueue.x+p7.x ,posQueue.y+p7.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p8  * tex2Dlod(SampFields, mul(float4(posQueue.x+p8.x ,posQueue.y+p8.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p9  * tex2Dlod(SampFields, mul(float4(posQueue.x+p9.x ,posQueue.y+p9.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p10  *tex2Dlod(SampFields, mul(float4(posQueue.x+p10.x ,posQueue.y+p10.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p11  *tex2Dlod(SampFields, mul(float4(posQueue.x+p11.x ,posQueue.y+p11.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p12  *tex2Dlod(SampFields, mul(float4(posQueue.x+p12.x ,posQueue.y+p12.y,0,0), FieldsTransform)+ 0.5).b;
        
	
	
    float2 fieldsAdd = d_1n * force;

if(ResBang)
         {
         return resetPos;
         }
         else
         {
         posQueue.ba +=  fieldsAdd ;
         posQueue.ba *= VelFactor;
         posQueue.rg += PosVelAdd.rg + posQueue.ba  ;

         return posQueue;
         }
         
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float4 PS2(vs2ps In): COLOR
{
    float4 posQueue = tex2D(SampQueue, In.TexCd);
    float4 PosVelAdd = tex2D(SampAdd, In.TexCd);    
    
    bool ResBang = 0;
    float index = In.TexCd.x*XYres.x + In.TexCd.y*XYres.x*XYres.y;       
    if(emitIndex >= emitIndexPrev)
      { ResBang = index > emitIndexPrev && index <= emitIndex;}
    else
      { ResBang = 1-(index < emitIndexPrev && index >= emitIndex); }
    
 /*   float indexU = 0;
    if(emitIndex >= emitIndexPrev)
      { indexU = (index - emitIndexPrev)/emitterCount ;}  
    else
      { indexU = 1-(index < emitIndexPrev && index >= emitIndex); }
 */   
    
    
    float4 resetPos = tex2D(SampResPos, float2(index/emitterCount,0));
    
	
	float2 p1 = ( float2(0.5000 ,  0.0000)*radius);
	float2 p2 = ( float2(0.3536 ,  0.3536)*radius);
	float2 p3 = ( float2(0.0000 ,  0.5000)*radius);
	float2 p4 = ( float2(-0.3536,  0.3536)*radius);
	float2 p5 = ( float2(-0.5000,  0.0000)*radius);
	float2 p6 = ( float2(-0.3536, -0.3536)*radius);
	float2 p7 = ( float2(0.0000 , -0.5000)*radius);
	float2 p8 = ( float2(0.3536 , -0.3536)*radius);
	
	float2 d_1n  =  p1  * tex2Dlod(SampFields, mul(float4(posQueue.x+p1.x ,posQueue.y+p1.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p2  * tex2Dlod(SampFields, mul(float4(posQueue.x+p2.x ,posQueue.y+p2.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p3  * tex2Dlod(SampFields, mul(float4(posQueue.x+p3.x ,posQueue.y+p3.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p4  * tex2Dlod(SampFields, mul(float4(posQueue.x+p4.x ,posQueue.y+p4.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p5  * tex2Dlod(SampFields, mul(float4(posQueue.x+p5.x ,posQueue.y+p5.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p6  * tex2Dlod(SampFields, mul(float4(posQueue.x+p6.x ,posQueue.y+p6.y,0,0), FieldsTransform)+ 0.5).b;
           d_1n +=  p7  * tex2Dlod(SampFields, mul(float4(posQueue.x+p7.x ,posQueue.y+p7.y,0,0), FieldsTransform)+ 0.5).b;
	       d_1n +=  p8  * tex2Dlod(SampFields, mul(float4(posQueue.x+p8.x ,posQueue.y+p8.y,0,0), FieldsTransform)+ 0.5).b;
        
	
	
    float2 fieldsAdd = d_1n * force;

if(ResBang)
         {
         return resetPos;
         }
         else
         {
       
         posQueue.rg += PosVelAdd.rg + fieldsAdd  ;

         return posQueue;
         }
         
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Fields_to_Position
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 PS1();
    }
}

technique Fields_to_Velocity
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 PS2();
    }
}

