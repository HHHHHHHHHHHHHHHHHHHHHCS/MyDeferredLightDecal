using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class DeferredDecalRenderer : MonoBehaviour
{
    public Mesh cubeMesh;

    private Dictionary<Camera, CommandBuffer> cameras = new Dictionary<Camera, CommandBuffer>();

    private void OnDisable()
    {
        foreach (var cam in cameras)
        {
            if (cam.Key)
            {
                cam.Key.RemoveCommandBuffer(CameraEvent.BeforeLighting, cam.Value);
            }
        }
    }

    private void OnWillRenderObject()
    {
        var act = gameObject.activeInHierarchy && enabled;
        if (!act)
        {
            OnDisable();
            return;
        }

        var cam = Camera.current;
        if (!cam)
            return;

        CommandBuffer buf = null;
        if (cameras.ContainsKey(cam))
        {
            buf = cameras[cam];
            buf.Clear();
        }
        else
        {
            buf = new CommandBuffer();
            buf.name = "Deferred Decals";
            cameras[cam] = buf;


            cam.AddCommandBuffer(CameraEvent.BeforeLighting, buf);
        }
    }
}