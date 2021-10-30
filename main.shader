float rect(vec2 _st, vec2 pos, vec2 wh, float edge_blur){
    

    //float t = step(pos.y, 1.0 - _st.y);
    //float l = step(pos.x, _st.x);
    //float b = step(1.0 - wh.y-pos.y, _st.y);
    //float r = step(1.0 - wh.x-pos.x, 1.0 - _st.x);
    
    //return t*l*b*r;
    vec4 tlbr = vec4(pos.y, 			//t
                     pos.x, 			//l
                     1.0 - wh.y-pos.y,  //b
                     1.0 - wh.x-pos.x); //r
    vec4 _sta = vec4(1.0 - _st.y, _st.x, _st.y, 1.0-_st.x);
    
    tlbr = smoothstep(tlbr, tlbr + vec4(edge_blur), _sta);
    
    return tlbr.x * tlbr.y * tlbr.w * tlbr.z;
}
