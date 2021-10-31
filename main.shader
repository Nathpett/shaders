float rect_a(vec2 _st, vec2 pos, vec2 wh, float edge_blur){

    // pos --- top left position of rectangle
    // wh --- width and height of rectangle
    // edge_blur --- degree of blurring around rect's edge
     
    //return t*l*b*r;
    vec4 tlbr = vec4(pos.y, 			//t
                     pos.x, 			//l
                     1.0 - wh.y-pos.y,  //b
                     1.0 - wh.x-pos.x); //r
    vec4 _sta = vec4(1.0 - _st.y, _st.x, _st.y, 1.0-_st.x);
    
    tlbr = smoothstep(tlbr, tlbr + vec4(edge_blur), _sta);
    
    return tlbr.x * tlbr.y * tlbr.w * tlbr.z;
}

float rect_b(vec2 st, vec2 ulim, vec2 llim){
    // simple rect
    // ulim --- x y coordinates at which the rectangle starts
    // llim --- xy coordinates at which the rectangle stops 
    
    vec2 bl = step(vec2(ulim.x, ulim.y),st);
    vec2 tr = step(vec2(1.0 - llim.x, 1.0 - llim.y),1.0-st);

    return bl.x * bl.y * tr.x * tr.y;
}
