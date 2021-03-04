//Play the footstep sound with a footStepDelay (set in the Inspector) delay between plays. 


using UnityEngine;

public class Footsteps : MonoBehaviour
{
    public AudioClip walkSound;
    public AudioSource source;
    public float footStepDelay;

    private float nextFootstep = 0;

    void Update()
    {
        if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.S)|| Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.W))
        {
            nextFootstep -= Time.deltaTime;
            if (nextFootstep <= 0)
            {
                source.PlayOneShot(walkSound, 0.01f);
                nextFootstep += footStepDelay;
            }
        }
        else
        {
            source.Stop();
        }
    }
}
