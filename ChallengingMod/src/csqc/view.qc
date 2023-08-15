float mod_bobTime; // Время для отслеживания текущей позиции в эффекте шатания

void CSQC_Init( void ) {

}

float CSQC_InputEvent( float flEventType, float flKey, float flCharacter ) {
  switch(flEventType) {
      case IE_KEYDOWN:
          OnIeKeydown(flEventType, flKey);

          break;

	case IE_KEYUP:
		return FALSE;	//don't break things if the menu was enabled mid-game while other keys are potentially still held, or some other way.
	case IE_MOUSEDELTA:
		//note: we can cope with multiple separate mouse devices here.
		mousecursor_x += scanx;
		mousecursor_y += chary;
		return TRUE; //don't change view angles
	case IE_MOUSEABS:
		if (devid != 0)	//no stuttering please.
			return FALSE;
		mousecursor_x = scanx;
		mousecursor_y = chary;
		return TRUE; //don't change view angles
	default:
		break;
	}

    return FALSE;
}

void CSQC_UpdateView( float flWidth, float flHeight ) {
  clearscene();

  // Manipulate view, add entities here
  setproperty( VF_DRAWWORLD, TRUE );
  setproperty( VF_DRAWENGINESBAR, TRUE );
  setproperty( VF_DRAWCROSSHAIR, TRUE );
  addentities( 
    ( intermission ? 0 : MASK_ENGINEVIEWMODELS ) | MASK_ENGINE 
  );

  renderscene();

  // Any 2D elements will be here
}

float CSQC_ConsoleCommand( string strCommand ) {
    return FALSE;
}

void CSQC_Shutdown( void ) {

}

