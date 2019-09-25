using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BlurAnim : MonoBehaviour
{
    public enum EffectType
    {
        Dither = 0,
        Replace
    }

    public Material effectMat;
    public EffectType effectType;
    public Transform target;
    public int sampleNum = 3;
    public float blurRadius = 0.2f;

    private CommandBuffer stencilFixCB, blurCB;
    private int blurTempRT1;

    private void OnEnable()
    {
        stencilFixCB = new CommandBuffer();
        stencilFixCB.name = "Stencil";

        foreach (var item in target.GetComponentsInChildren<Renderer>())
        {
            //shaderPass  是 -1    就是把全部的Pass都画一次
            stencilFixCB.DrawRenderer(item, effectMat, 0, (int) effectType);
        }

        Camera.main.AddCommandBuffer(CameraEvent.AfterSkybox, stencilFixCB);

        blurCB = new CommandBuffer();
        blurCB.name = "Blur";
        blurTempRT1 = Shader.PropertyToID("BlurTempRT1");
        blurCB.GetTemporaryRT(blurTempRT1, -2, -2, 0);
        blurCB.Blit(BuiltinRenderTextureType.CameraTarget, blurTempRT1);

        for (int i = 0; i < sampleNum - 1; i++)
        {
            blurCB.Blit(blurTempRT1, BuiltinRenderTextureType.CameraTarget, effectMat, 2);
            blurCB.Blit(BuiltinRenderTextureType.CameraTarget, blurTempRT1);
        }

        blurCB.Blit(blurTempRT1, BuiltinRenderTextureType.CameraTarget, effectMat, 2);
        Camera.main.AddCommandBuffer(CameraEvent.BeforeImageEffects, blurCB);
    }

    private void Update()
    {
        blurRadius = Mathf.Sin(Time.realtimeSinceStartup * 5);
        effectMat.SetFloat("_BlurRadius", blurRadius);
    }

    private void OnDisable()
    {
        blurCB.ReleaseTemporaryRT(blurTempRT1);

        Camera.main.RemoveCommandBuffer(CameraEvent.AfterSkybox, stencilFixCB);
        stencilFixCB.Dispose();

        Camera.main.AddCommandBuffer(CameraEvent.BeforeImageEffects, blurCB);
        blurCB.Dispose();
    }
}