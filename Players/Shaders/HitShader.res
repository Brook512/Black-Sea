RSRC                    VisualShader            #�ݶDi�~                                            G      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script    source    texture    texture_type    op_type 	   constant 	   operator 	   function    _limits    bake_resolution    _data    point_count    width    texture_mode    curve    size    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    flags/world_vertex_coords    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/13/node    nodes/fragment/13/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        $   local://VisualShaderNodeInput_yx35o �	      &   local://VisualShaderNodeTexture_5161f �	      .   local://VisualShaderNodeVectorDecompose_nynvh �	      ,   local://VisualShaderNodeVectorCompose_aqdku i
      +   local://VisualShaderNodeVec3Constant_yx35o �
      '   local://VisualShaderNodeVectorOp_5161f �
      $   local://VisualShaderNodeInput_nynvh       (   local://VisualShaderNodeFloatFunc_aqdku D      '   local://VisualShaderNodeVectorOp_yx35o z         local://Curve_yx35o �         local://CurveTexture_yx35o u      +   local://VisualShaderNodeCurveTexture_5161f �      $   res://Players/Shaders/HitShader.res �         VisualShaderNodeInput             texture          VisualShaderNodeTexture                       VisualShaderNodeVectorDecompose                                                                   VisualShaderNodeVectorCompose                       VisualShaderNodeVec3Constant            �?  �?  �?         VisualShaderNodeVectorOp             VisualShaderNodeInput             time          VisualShaderNodeFloatFunc                       VisualShaderNodeVectorOp                                Curve          -   
                                       
   �D�=                                
   2��=  �?                            
   I�:>  �?                            
   }>>>                                
   ���>                                
   *��>  �?                            
   �0 ?  �?                            
   s?                                      	            CurveTexture             	            VisualShaderNodeCurveTexture              	         
            VisualShader          %  shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D curve_frg_13 : repeat_disable;



void fragment() {
	vec4 n_out3p0;
// Texture2D:3
	n_out3p0 = texture(TEXTURE, UV);


// VectorDecompose:4
	float n_out4p0 = n_out3p0.x;
	float n_out4p1 = n_out3p0.y;
	float n_out4p2 = n_out3p0.z;
	float n_out4p3 = n_out3p0.w;


// VectorCompose:5
	vec3 n_out5p0 = vec3(n_out4p0, n_out4p1, n_out4p2);


// Vector3Constant:6
	vec3 n_out6p0 = vec3(1.000000, 1.000000, 1.000000);


// Input:8
	float n_out8p0 = TIME;


// FloatFunc:9
	float n_out9p0 = sin(n_out8p0);


// CurveTexture:13
	float n_out13p0 = texture(curve_frg_13, vec2(n_out9p0)).r;


// VectorOp:12
	vec3 n_out12p0 = n_out6p0 * vec3(n_out13p0);


// VectorOp:7
	vec3 n_out7p0 = n_out5p0 + n_out12p0;


// Output:0
	COLOR.rgb = n_out7p0;


}
                    !   
     9D  �B"             #   
     9�  4C$            %   
     ��  �B&            '   
     �  �B(            )   
     �B  �B*            +   
     ��  *D,            -   
     �C  \C.            /   
     H�  fD0            1   
     ��  fD2            3   
      C  D4            5   
     ��  fD6       0                                                                                         	                                                 	                                 RSRC