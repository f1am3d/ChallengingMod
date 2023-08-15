void CameraBob() 
{
    if(mod_bobTime < 1) {
        mod_bobTime += frametime; 
        
        // Интерполяция между начальным и конечным углом
        // float pitchChange = lerp(0, 10, mod_bobTime); // Поднять камеру на 10 градусов и вернуть обратно
        
        // Примените изменение к углу камеры
        // view_angles[PITCH] += pitchChange;
    }
    else 
    {
        mod_bobTime = 0; // Сбросить время
    }
}
