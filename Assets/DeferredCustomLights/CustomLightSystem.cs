using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomLightSystem
{
    private static CustomLightSystem instance;

    public static CustomLightSystem Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new CustomLightSystem();
            }

            return instance;
        }
    }

    public HashSet<CustomLight> lights = new HashSet<CustomLight>();

    public void Add(CustomLight light)
    {
        Remove(light);
        lights.Add(light);
    }

    public void Remove(CustomLight light)
    {
        lights.Remove(light);
    }
}