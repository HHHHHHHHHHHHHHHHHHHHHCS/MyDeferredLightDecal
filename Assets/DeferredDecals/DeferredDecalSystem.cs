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
}