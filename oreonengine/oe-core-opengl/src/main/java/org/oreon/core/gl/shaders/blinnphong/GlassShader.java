package org.oreon.core.gl.shaders.blinnphong;

import org.oreon.core.gl.light.GLDirectionalLight;
import org.oreon.core.gl.shaders.GLShader;
import org.oreon.core.model.Material;
import org.oreon.core.scene.GameObject;
import org.oreon.core.system.CoreSystem;
import org.oreon.core.util.ResourceLoader;

public class GlassShader extends GLShader{
	
	private static GlassShader instance;

	public static GlassShader getInstance() 
	{
	    if(instance == null) 
	    {
	    	instance = new GlassShader();
	    }
	     return instance;
	}
	
	protected GlassShader()
	{
		super();

		addVertexShader(ResourceLoader.loadShader("shaders/blinn-phong/glass/Vertex.glsl"));
		addFragmentShader(ResourceLoader.loadShader("shaders/blinn-phong/glass/Fragment.glsl"));
		compileShader();
		
		addUniform("modelViewProjectionMatrix");
		addUniform("worldMatrix");
		addUniform("eyePosition");
		addUniform("directionalLight.intensity");
		addUniform("directionalLight.color");
		addUniform("directionalLight.direction");
		addUniform("directionalLight.ambient");
		addUniform("material.color");
		addUniform("material.emission");
		addUniform("material.shininess");
	}
	
	public void updateUniforms(GameObject object)
	{
		setUniform("modelViewProjectionMatrix", object.getWorldTransform().getModelViewProjectionMatrix());
		setUniform("worldMatrix", object.getWorldTransform().getWorldMatrix());
		setUniform("eyePosition", CoreSystem.getInstance().getScenegraph().getCamera().getPosition());
		setUniform("directionalLight.ambient", GLDirectionalLight.getInstance().getAmbient());
		setUniformf("directionalLight.intensity", GLDirectionalLight.getInstance().getIntensity());
		setUniform("directionalLight.color", GLDirectionalLight.getInstance().getColor());
		setUniform("directionalLight.direction", GLDirectionalLight.getInstance().getDirection());
		Material material = (Material) object.getComponent("Material");
		setUniform("material.color", material.getColor());
		setUniformf("material.emission", material.getEmission());
		setUniformf("material.shininess", material.getShininess());
	}
}

