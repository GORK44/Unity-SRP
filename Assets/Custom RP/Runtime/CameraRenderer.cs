using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRenderer
{

    ScriptableRenderContext context;

    Camera camera;

    const string bufferName = "Render Camera";

    CommandBuffer buffer = new CommandBuffer //CommandBuffer 命令缓冲区
    {
        name = bufferName
    };

    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");





    public void Render(ScriptableRenderContext context, Camera camera,
        bool useDynamicBatching, bool useGPUInstancing)
    {
        this.context = context;
        this.camera = camera;

        PrepareBuffer();
        PrepareForSceneWindow();

        if (!Cull()) //调用剔除。如果失败，终止
        {
            return;
        }

        Setup(); //设定
        DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
        DrawUnsupportedShaders();//绘制不受支持的shader
        DrawGizmos();//绘制视锥体辅助线，相机图标，灯光图标等
        Submit(); //提交
    }






    void DrawVisibleGeometry (bool useDynamicBatching, bool useGPUInstancing)
    {
        //---------
        //绘制不透明物体
        var sortingSettings = new SortingSettings(camera) //排序设置
        {
            criteria = SortingCriteria.CommonOpaque //分类标准.通用不透明
        }; 

        var drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings)
        {
            enableDynamicBatching = useDynamicBatching,  //动态批处理
            enableInstancing = useGPUInstancing  //GPU实例化
        };
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque); //渲染队列范围.不透明

        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );
        //---------


        context.DrawSkybox(camera); //绘制天空盒


        //---------
        //绘制透明物体
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;

        context.DrawRenderers(
            cullingResults, ref drawingSettings, ref filteringSettings
        );
        //---------
    }




    void Setup() //设定
    {
        context.SetupCameraProperties(camera); //设定相机属性（四分之一屏到全屏）

        buffer.ClearRenderTarget(true, true, Color.clear); //Clear (color+Z+stencil)（参数：depth，color，填充的颜色）

        buffer.BeginSample(SampleName);
        ExecuteBuffer();

    }


    void Submit() //提交
    {
        buffer.EndSample(SampleName);
        ExecuteBuffer();

        context.Submit();
    }


    void ExecuteBuffer() //执行缓冲区
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear(); //清除
    }


    CullingResults cullingResults; //剔除结果

    bool Cull() //剔除
    {
        //ScriptableCullingParameters p 
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p)) //尝试获取剔除参数（可脚本化的剔除参数）
        {
            cullingResults = context.Cull(ref p);
            return true;
        }
        return false;
    }

}
