import Engine from './engine/engine.js';
import RenderPipelineBuilder from './engine/renderPipeline.js';

export default async function webgpu() {
  const canvas = document.querySelector('canvas');
  const engine  = await Engine.initialize(canvas);
  const device = engine.device;
  
  
  const shaderModule = device.createShaderModule({
    code: triangleShaderCode
  })

  const pipelineBuilder = new RenderPipelineBuilder(device);
  const renderPipeline = pipelineBuilder
    .setPipelineLayout(device.createPipelineLayout({ bindGroupLayouts: [] }))
    .setShaderModule(shaderModule)
    .setVertexBuffers([bufferLayout])
    .setTargetFormats([engine.canvasFormat])
    .setPrimitive("triangle-list")
    .build()
  const commandBuffer = engine.encodeRenderPass(3, renderPipeline, vertexBuffer);
  await engine.submitCommand(commandBuffer);
}

webgpu(); 
