using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SampleDraw : MonoBehaviour
{
    public Transform parent;

    private CommandBuffer cacheCommandBuffer1, cacheCommandBuffer2;

    private void OnEnable()
    {
        cacheCommandBuffer1 = new CommandBuffer();
        cacheCommandBuffer1.name = "CB1";
        //如果第四个参数写-1 则会渲染全部的Pass
        foreach (var item in parent.GetComponentsInChildren<Renderer>())
        {
            cacheCommandBuffer1.DrawRenderer(item, item.sharedMaterial, 0, 0);
        }
        Camera.main.AddCommandBuffer(CameraEvent.AfterGBuffer, cacheCommandBuffer1);


        cacheCommandBuffer2 = new CommandBuffer();
        cacheCommandBuffer2.name = "CB2";
        foreach (var item in parent.GetComponentsInChildren<Renderer>())
        {
            cacheCommandBuffer2.DrawRenderer(item, item.sharedMaterial, 0, 0);
        }
        Camera.main.AddCommandBuffer(CameraEvent.AfterLighting, cacheCommandBuffer2);
    }

    private void OnDisable()
    {
        Camera.main.RemoveCommandBuffer(CameraEvent.AfterGBuffer, cacheCommandBuffer1);
        cacheCommandBuffer1.Dispose();

        Camera.main.RemoveCommandBuffer(CameraEvent.AfterLighting, cacheCommandBuffer2);
        cacheCommandBuffer2.Dispose();
    }
}