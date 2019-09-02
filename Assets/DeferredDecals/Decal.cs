using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Decal : MonoBehaviour
{
    public enum DecalType
    {
        DiffuseOnly,
        NormalOnly,
        Both,
    }

    public DecalType decalType;
    public Material material;

    private void OnEnable()
    {
    }

    private void Start()
    {
    }

    private void OnDisable()
    {
    }

    private void DrawGizmo(bool selected)
    {
        var col = new Color(0.0f, 0.7f, 1.0f, 1.0f);
        col.a = selected ? 0.1f : 0.1f;
        Gizmos.color = col;
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawCube(Vector3.zero,Vector3.one);
        col.a = selected ? 0.5f : 0.2f;
        Gizmos.color = col;
        Gizmos.DrawWireCube(Vector3.zero,Vector3.one);
    }

    private void OnDrawGizmos()
    {
        DrawGizmo(false);
    }

    private void OnDrawGizmosSelected()
    {
        DrawGizmo(true);
    }
}