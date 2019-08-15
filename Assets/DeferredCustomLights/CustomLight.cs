using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CustomLight : MonoBehaviour
{
    public enum Kind
    {
        Sphere,
        Tube,
    }

    public Kind type;
    public Color color = Color.white;
    public float intensity = 1.0f;
    public float range = 10.0f;
    public float size = 0.5f;
    public float tubeLength = 1.0f;

    private void OnEnable()
    {
        throw new System.NotImplementedException();
    }

    private void Start()
    {
        throw new System.NotImplementedException();
    }

    private void OnDisable()
    {
        throw new System.NotImplementedException();
    }

    public Color GetLinearColor()
    {
        return new Color(
            Mathf.GammaToLinearSpace(color.r * intensity),
            Mathf.GammaToLinearSpace(color.g * intensity),
            Mathf.GammaToLinearSpace(color.b * intensity),
            1.0f
        );
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawIcon(transform.position,type==Kind.Tube?"AreaLight Gizmo":"PointLight Gizmo",true);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0.1f,0.7f,1.0f,0.6f);
        if (type == Kind.Tube)
        {
            Gizmos.matrix = Matrix4x4.TRS(transform.position,transform.rotation,new Vector3(tubeLength*2,size*2,size*2));
            Gizmos.DrawWireCube(Vector3.zero,Vector3.one);
        }
        else
        {
            Gizmos.matrix=Matrix4x4.identity;
            Gizmos.DrawWireSphere(transform.position,size);
        }
        Gizmos.matrix=Matrix4x4.identity;
        ;
        Gizmos.DrawWireSphere(transform.position,range);
    }
}