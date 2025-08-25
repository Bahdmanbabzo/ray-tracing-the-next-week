import Engine from './engine/engine.js';
import RenderPipelineBuilder from './engine/renderPipeline.js';
import quadShaderCode from './shaders/quad.wgsl?raw';
import rayTracer from './shaders/rayTracer.wgsl?raw';
import { Hittable } from './hittables.js';

export default async function webgpu() {
  const canvas = document.querySelector('canvas');
  const engine  = await Engine.initialize(canvas);
  const device = engine.device;

  // Set the canvas size to match the window size and device pixel ratio
  // This ensures that the canvas is rendered at the correct resolution
  const devicePixelRatio = window.devicePixelRatio || 1;
  canvas.width = window.innerWidth * devicePixelRatio;
  canvas.height = window.innerHeight * devicePixelRatio ;

  canvas.style.width = `${window.innerWidth}px`;
  canvas.style.height = `${window.innerHeight}px`;

  const vertexData = new Float32Array([
    // x,    y
    -1.0, -1.0, 
     1.0, -1.0, 
    -1.0,  1.0, 
    -1.0,  1.0, 
     1.0, -1.0, 
     1.0,  1.0 
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

  const canvasSize = new Float32Array([
    canvas.width,
    canvas.height
  ]); 
  const canvasSizeBuffer = device.createBuffer({
    size: canvasSize.byteLength,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
  });
  device.queue.writeBuffer(canvasSizeBuffer, 0, canvasSize);

  const debugBuffer = device.createBuffer({
    size: 16,
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC
  });
  device.queue.writeBuffer(debugBuffer, 0, new Float32Array([0.0, 0.0, 0.0]));

  const spheres = [
    new Hittable([0.0, 0.0, -6.0, 0.0], 1.0, 1.0, [1.0, 0.6, 0.2, 0.0], 0.03),
    new Hittable([2.0, 0.0, -7.0, 0.0], 0.5, 1.0, [1.0, 1.0, 1.0, 0.0], 0.3),
    new Hittable([-2.0, 0.0, -8.0, 0.0], 0.5, 1.0, [0.8, 0.8, 1.0, 0.0], 0.1)
  ];
  const allData = spheres.flatMap(sphere => sphere.arrayFormat);
  const hittablesData = new Float32Array(allData);
  console.log(hittablesData)
  const hittablesBuffer = device.createBuffer({
    size: 192,
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST
  });
  device.queue.writeBuffer(hittablesBuffer, 0, hittablesData);
  console.log(hittablesBuffer)

  const hittablesCountBuffer = device.createBuffer({
    size: 4,
    usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
  });
  device.queue.writeBuffer(hittablesCountBuffer, 0, new Int32Array([3]));

  const shaderModule = device.createShaderModule({
    code: rayTracer
  })

  const pipelineBuilder = new RenderPipelineBuilder(device);
  const renderPipeline = pipelineBuilder
    .setShaderModule(shaderModule)
    .setVertexBuffers([bufferLayout])
    .setTargetFormats([engine.canvasFormat])
    .setPrimitive("triangle-list")
    .build()

   const bindGroupLayout = renderPipeline.getBindGroupLayout(0);

  // Create the bind group
  let bindGroup = device.createBindGroup({
      layout: bindGroupLayout,
      entries: [
        { binding: 0, resource: { buffer: canvasSizeBuffer }}, 
        { binding: 1, resource: { buffer: hittablesBuffer}},
        { binding: 2, resource: { buffer: hittablesCountBuffer }}
      ]
  });
  const commandBuffer = engine.encodeRenderPass(6, renderPipeline, vertexBuffer, bindGroup);
  await engine.submitCommand(commandBuffer);
}

webgpu(); 
