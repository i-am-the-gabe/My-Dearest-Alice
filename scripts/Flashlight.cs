using UnityEngine;
using UnityEngine.UI;

public class Flashlight : MonoBehaviour
{
    public Light myLight;
    public bool isOff = true;
    public float DefaultIntensity = 1f;
    public float MinimumIntensity = 1f;
    public Text FlashlightTip;

    void Start()
    {
        if (isOff)
        {
            myLight.intensity = 0;
        }
    }

    void Update()
    {

        if (Input.GetKeyDown("e"))
        {

            if (isOff)
            {
                myLight.intensity = DefaultIntensity;

                if (FlashlightTip.enabled) FlashlightTip.enabled = false;

                isOff = false;
            }
            else
            {
                myLight.intensity = 0;

                isOff = true;
            }

        }
    }
}
