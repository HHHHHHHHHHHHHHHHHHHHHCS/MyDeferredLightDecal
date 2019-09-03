using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeferredDecalSystem
{
    private static DeferredDecalSystem instance;

    public static DeferredDecalSystem Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new DeferredDecalSystem();
            }

            return instance;
        }
    }


    private HashSet<Decal> decalDiffuse = new HashSet<Decal>();
    private HashSet<Decal> decalNormals = new HashSet<Decal>();
    private HashSet<Decal> decalBoth = new HashSet<Decal>();

    public void AddDecal(Decal d)
    {
        RemoveDecal(d);
        if (d.decalType == Decal.DecalType.DiffuseOnly)
        {
            decalDiffuse.Add(d);
        }
        else if (d.decalType == Decal.DecalType.NormalOnly)
        {
            decalNormals.Add(d);
        }
        else if (d.decalType == Decal.DecalType.Both)
        {
            decalBoth.Add(d);
        }
    }

    public void RemoveDecal(Decal d)
    {
        decalDiffuse.Remove(d);
        decalNormals.Remove(d);
        decalBoth.Remove(d);
    }
}