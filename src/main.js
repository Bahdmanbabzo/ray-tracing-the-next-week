import Engine from './engine/engine.js';
import RenderPipelineBuilder from './engine/renderPipeline.js';
import quadShaderCode from './shaders/quad.wgsl?raw';

export default async function webgpu() {
  const canvas = document.querySelector('canvas');
  const engine  = await Engine.initialize(canvas);
  const device = engine.device;

  const vertexData = new Float32Array([
    // x,    y
    -1.0, -1.0, // bottom left
     1.0, -1.0, // bottom right
    -1.0,  1.0, // top left
    -1.0,  1.0, // top left
     1.0, -1.0, // bottom right
     1.0,  1.0  // top right
  ]);

  const vertexBuffer = device.createBuffer({
    size: vertexData.byteLength,
    usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
  });

  device.queue.writeBuffer(vertexBuffer, 0, vertexData);
  const bufferLayout = {
    arrayStride: 2 * 4,
    attributes: [
      { shaderLocation:0 , offset:0, format: 'float32x2'}
    ]
  };
  const shaderModule = device.createShaderModule({
    code: quadShaderCode
  })

  const pipelineBuilder = new RenderPipelineBuilder(device);
  const renderPipeline = pipelineBuilder
    .setPipelineLayout(device.createPipelineLayout({ bindGroupLayouts: [] }))
    .setShaderModule(shaderModule)
    .setVertexBuffers([bufferLayout])
    .setTargetFormats([engine.canvasFormat])
    .setPrimitive("triangle-list")
    .build()
  const commandBuffer = engine.encodeRenderPass(6, renderPipeline, vertexBuffer);
  await engine.submitCommand(commandBuffer);
}

webgpu(); 
