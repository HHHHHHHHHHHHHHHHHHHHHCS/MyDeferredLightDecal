using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CustomLightRenderer : MonoBehaviour
{
    private struct CmdBufferEntry
    {
        //为每个摄像头添加两个CommandBuffer
        //after 用于计算灯光的照明
        //before 用于绘制灯光的物体
        public CommandBuffer afterLighting;
        public CommandBuffer beforeAlpha;
    }

    public Shader lightShader;

    public Mesh cubeMesh;
    public Mesh sphereMesh;

    private Material lightMaterial;

    private Dictionary<Camera, CmdBufferEntry> cameras = new Dictionary<Camera, CmdBufferEntry>();

    private readonly int propParams = Shader.PropertyToID("_CustomLightParams");
    private readonly int propColor = Shader.PropertyToID("_CustomLightColor");

    private void OnDisable()
    {
        foreach (var cam in cameras)
        {
            if (cam.Key)
            {
                cam.Key.RemoveCommandBuffer(CameraEvent.AfterLighting, cam.Value.afterLighting);
                cam.Key.RemoveCommandBuffer(CameraEvent.BeforeForwardAlpha, cam.Value.beforeAlpha);
            }
        }

        DestroyImmediate(lightMaterial);
    }

    /// <summary>
    /// 如果对象可见，则为每个相机调用一次此函数
    /// </summary>
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

        if (!lightMaterial)
        {
            lightMaterial = new Material(lightShader) {hideFlags = HideFlags.HideAndDontSave};
        }

        CmdBufferEntry buf = new CmdBufferEntry();
        if (cameras.ContainsKey(cam))
        {//如果存在 清除之前写的命令
            buf = cameras[cam];
            buf.afterLighting.Clear();
            buf.beforeAlpha.Clear();
        }
        else
        {
            buf.afterLighting = new CommandBuffer {name = "Deferred Custom Lights"};
            buf.beforeAlpha = new CommandBuffer {name = "Draw light Shapes"};

            cameras[cam] = buf;

            cam.AddCommandBuffer(CameraEvent.AfterLighting, buf.afterLighting);
            cam.AddCommandBuffer(CameraEvent.BeforeForwardAlpha, buf.beforeAlpha);
        }

        //TODO:在一个真正的系统中，应该剔除灯光，而且可能只有在发生更改时重新创建命令缓冲区
        var system = CustomLightSystem.Instance;

        Vector4 param = Vector4.zero;
        Matrix4x4 trs = Matrix4x4.identity;

        foreach (var item in system.lights)
        {
            param.x = item.tubeLength;
            param.y = item.size;
            param.z = 1.0f / (item.range * item.range);
            param.w = (float) item.type;

            buf.afterLighting.SetGlobalColor(propParams, param);
            buf.afterLighting.SetGlobalColor(propColor, item.GetLinearColor());

            trs = Matrix4x4.TRS(item.transform.position, item.transform.rotation, Vector3.one * item.range * 2);
            buf.afterLighting.DrawMesh(sphereMesh, trs, lightMaterial, 0, 0);
        }

        foreach (var item in system.lights)
        {
            buf.beforeAlpha.SetGlobalColor(propColor, item.GetLinearColor());

            if (item.type == CustomLight.Kind.Sphere)
            {
                trs = Matrix4x4.TRS(item.transform.position, item.transform.rotation, Vector3.one * item.size * 2);
                buf.beforeAlpha.DrawMesh(sphereMesh,trs,lightMaterial,0,1);
            }
            else if (item.type == CustomLight.Kind.Tube)
            {
                trs = Matrix4x4.TRS(item.transform.position, item.transform.rotation, new Vector3(item.tubeLength * 2, item.size * 2, item.size * 2));
                buf.beforeAlpha.DrawMesh(cubeMesh, trs, lightMaterial, 0, 1);
            }
        }
    }
}