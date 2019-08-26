using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferBlurRefraction : MonoBehaviour
{
    private readonly int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
    private readonly int blurredID = Shader.PropertyToID("_Temp1");
    private readonly int blurredID2 = Shader.PropertyToID("_Temp2");


    public Shader blurShader;
    private Material material;

    private Dictionary<Camera, CommandBuffer> cameras = new Dictionary<Camera, CommandBuffer>();

    private void OnEnable()
    {
        Cleanup();
    }

    private void OnDisable()
    {
        Cleanup();
    }

    private void Cleanup()
    {
        foreach (var item in cameras)
        {
            if (item.Key)
            {
                item.Key.RemoveCommandBuffer(CameraEvent.AfterSkybox, item.Value);
            }
        }

        cameras.Clear();
        DestroyImmediate(material);
    }

    private void OnWillRenderObject()
    {
        var act = gameObject.activeInHierarchy && enabled;
        if (!act)
        {
            Cleanup();
            return;
        }

        var cam = Camera.current;
        if (!cam)
        {
            return;
        }

        CommandBuffer buf = null;
        if (cameras.ContainsKey(cam))
            return;

        if (!material)
        {
            material = new Material(blurShader) {hideFlags = HideFlags.HideAndDontSave};
        }

        buf = new CommandBuffer();
        buf.name = "Grab screen and blur";
        cameras[cam] = buf;

        buf.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        buf.Blit(BuiltinRenderTextureType.CurrentActive, screenCopyID);

        buf.GetTemporaryRT(blurredID, -2, -2, 0, FilterMode.Bilinear);
        buf.GetTemporaryRT(blurredID2, -2, -2, 0, FilterMode.Bilinear);

        buf.Blit(screenCopyID, blurredID);
        buf.ReleaseTemporaryRT(screenCopyID);

        buf.SetGlobalVector("offsets", new Vector4(2.0f / Screen.width, 0, 0, 0));
        buf.Blit(blurredID, blurredID2, material);

        buf.SetGlobalVector("offsets", new Vector4(0, 2.0f / Screen.height, 0, 0));
        buf.Blit(blurredID2, blurredID, material);

        buf.SetGlobalVector("offsets", new Vector4(4.0f / Screen.width, 0, 0, 0));
        buf.Blit(blurredID, blurredID2, material);

        buf.SetGlobalVector("offsets", new Vector4(0, 2.0f / Screen.height, 0, 0));
        buf.Blit(blurredID2, blurredID, material);

        buf.SetGlobalTexture("_GrabBlurTexture", blurredID);

        cam.AddCommandBuffer(CameraEvent.AfterSkybox, buf);
    }
}