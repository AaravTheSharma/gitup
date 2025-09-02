「决策助手：人生十字路口」

## 🆕 新功能：AI 多维度决策分析

### 功能特色
- **智能问题分析**: AI从8个维度深入分析用户问题（财务、情感、社会、职业、健康、时间、风险、机会）
- **决策框架推荐**: 根据问题特点推荐最适合的决策方法（SWOT、MCDA、成本效益分析等）
- **风险评估**: 识别每个选项的风险和机会，提供缓解措施
- **结构化输出**: 提供问题分类、紧急程度评估、具体建议和行动步骤

### 使用方法
1. 在主页点击"AI Analysis"按钮
2. 详细描述你的决策问题
3. 获得多维度分析结果和专业建议
4. 可选择将分析结果转化为正式的决策项目

### 示例分析
**问题**: "我应该换工作吗？现在的工作稳定但成长空间有限..."

**AI分析结果**:
- 问题类型: 职业决策 (紧急程度: 3/5, 复杂程度: 4/5)
- 财务维度: 评估薪资变化、搬迁成本、生活成本差异
- 情感维度: 考虑对变化的适应能力和心理压力
- 职业维度: 分析长期发展机会和技能提升空间
- 推荐框架: 多标准决策分析(MCDA)
- 具体建议: 制定详细预算、与家人沟通、了解新公司文化

功能描述：超越普通的抛硬币。用户可以输入一个复杂的决策选项（如“该不该换工作”），App利用deepseek ai系统统，引导用户从薪资、发展、幸福感等多个维度打分，最后生成一个可视化的决策矩阵和分析报告，帮助用户理清思路。

亮点：将专业的决策模型（如加权决策矩阵）做成了轻量级工具

app是：英文


curl
python
nodejs
curl https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Authorization: Bearer <DeepSeek API Key>" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello!"}
    ],
    "stream": false
  }'


jsonDecode(utf8.decode(response.bodyBytes));


      key:sk-4482f345cc9e4270b61e94558047afa3



Clarity - 决策助手 Flutter 应用架构与需求文档
1. 项目概述
Clarity是一款旨在帮助用户清晰、结构化地做出复杂决策的移动应用。用户可以通过定义决策选项、设定评估标准、为标准分配权重，并为各选项打分，最终生成一份直观的可视化分析报告。本项目旨在将Web原型（index.html）实现为一个独立的、数据存储于本地的Flutter应用。

2. 核心需求
功能性需求

决策管理:

创建新的决策，包括定义决策标题和多个选项。

从预设模板（如职业、住房、财务等）快速开始一个新的决策。

查看进行中和已完成的决策列表。

归档已完成的决策。

决策流程:

设定标准: 为每个决策选择或自定义多个评估标准（Criteria）。

分配权重: 通过滑块为每个标准设置其在决策中的重要性（权重）。

选项评分: 针对每个标准，为所有选项进行评分（例如1-10分）。

分析报告:

根据权重和评分自动计算每个选项的最终得分。

以雷达图等可视化形式直观对比各个选项在不同标准下的表现。

展示最终推荐的选项和关键分析摘要。

数据洞察:

统计用户在所有决策中最看重的评估标准（条形图）。

分析用户创建的决策类型分布（甜甜圈图）。

应用设置:

支持浅色/深色主题切换。

提供导出和清除所有本地数据的功能。

非功能性需求

数据持久化: 所有用户数据（决策、设置等）均存储在设备本地，应用无需联网。

响应式UI: 界面应在不同尺寸的手机屏幕上保持良好的视觉和交互体验。

离线优先: 应用所有核心功能均可完全离线使用。

低耦合架构: 模块间应尽可能解耦，便于维护和未来扩展。

技术栈与约束

UI框架: Flutter

状态管理: setState (初期版本，保持简单)

数据存储: shared_preferences (用于存储决策列表和用户设置)

图表: fl_chart 或类似的轻量级图表库。

禁止使用:

freezed 和 part 语法

账户系统及任何云同步功能

本地图片资源 (assets/images/)

cached_network_image

外部字体文件

share_plus 等分享插件

3. 应用架构
本应用采用分层架构，确保UI、业务逻辑和数据层分离，以降低耦合度。

UI层 (Presentation Layer):

包含所有界面（Screens）和可复用的组件（Widgets）。

负责渲染UI和处理用户输入事件。

通过调用业务逻辑层的服务来更新状态和执行操作。

状态管理完全通过 StatefulWidget 和 setState 实现。

业务逻辑层 (Business Logic Layer):

包含处理核心业务逻辑的 Service 类。

例如 DecisionService 负责计算决策得分、生成报告摘要等。

这一层不直接与UI或数据存储交互，而是作为二者之间的桥梁。

数据层 (Data Layer):

负责数据的持久化和检索。

StorageService 封装了对 shared_preferences 的所有读写操作，将决策对象序列化为JSON字符串进行存储。

向上层提供统一的数据访问接口。

模型层 (Model Layer):

定义应用的核心数据结构，如 Decision, Option, Criterion。

每个模型类包含 toJson 和 fromJson 方法，以便于序列化和反序列化。

4. 文件结构与功能说明
lib/
|
├── main.dart             # App入口，配置主题和路由
|
├── core/
│   ├── app_constants.dart  # 应用级常量，如颜色、边距
│   └── app_theme.dart      # 定义浅色和深色主题
|
├── data/
│   ├── models/
│   │   ├── decision_model.dart # 决策数据模型
│   │   ├── option_model.dart   # 选项数据模型
│   │   └── criterion_model.dart# 标准数据模型
│   └── services/
│       └── storage_service.dart  # 封装shared_preferences的本地存储服务
|
├── logic/
│   └── decision_service.dart # 决策相关的业务逻辑，如分数计算
|
├── presentation/
│   ├── screens/
│   │   ├── main_screen.dart    # 主界面，包含BottomNavigationBar和页面切换逻辑
│   │   │
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart # 首页，展示最近决策
│   │   │
│   │   ├── new_decision/     # 创建新决策的流程页面
│   │   │   ├── templates_screen.dart
│   │   │   ├── create_decision_screen.dart
│   │   │   ├── select_criteria_screen.dart
│   │   │   ├── set_weights_screen.dart
│   │   │   └── score_options_screen.dart
│   │   │
│   │   ├── report/
│   │   │   └── report_screen.dart # 决策报告页
│   │   │
│   │   ├── archive/
│   │   │   └── archive_screen.dart # 归档页
│   │   │
│   │   ├── insights/
│   │   │   └── insights_screen.dart # 数据洞察页
│   │   │
│   │   └── settings/
│   │       └── settings_screen.dart # 设置页
│   │
│   └── widgets/              # 可复用的UI组件
│       ├── custom_card.dart
│       ├── primary_button.dart
│       ├── decision_list_item.dart
│       └── radar_chart_widget.dart # 雷达图组件
│
└── utils/
    └── helpers.dart          # 辅助函数，如日期格式化


5. 数据模型定义
Criterion (标准)

id: String - 唯一标识符。

name: String - 标准的名称 (如 "薪水")。

weight: double - 权重 (0.0 到 1.0)。

Option (选项)

id: String - 唯一标识符。

name: String - 选项的名称 (如 "接受新工作")。

scores: Map<String, int> - 评分表，Key为Criterion的ID，Value为分数 (1-10)。

Decision (决策)

id: String - 唯一标识符 (可以使用 uuid 包生成)。

title: String - 决策的标题。

options: List<Option> - 包含的选项列表。

criteria: List<Criterion> - 评估标准列表。

status: String - 决策状态 ('in-progress', 'completed', 'archived')。

creationDate: DateTime - 创建日期。

每个模型都需实现 Map<String, dynamic> toJson() 和 factory YourModel.fromJson(Map<String, dynamic> json) 方法。

6. 实现计划与关键步骤
第一阶段：项目搭建与核心模型

创建Flutter项目，配置flutter_lints。

搭建上述文件结构。

实现 decision_model.dart, option_model.dart, criterion_model.dart，包含 toJson/fromJson 方法。

开发 storage_service.dart，封装 shared_preferences 的 saveDecisions 和 loadDecisions 方法（处理JSON字符串与模型列表的转换）。

第二阶段：主导航与核心页面

创建 main_screen.dart，使用 BottomNavigationBar 和 PageView 或 IndexedStack 实现底部导航栏和页面切换。

创建 dashboard_screen.dart, archive_screen.dart, insights_screen.dart, settings_screen.dart 的基本布局。

dashboard_screen 从 StorageService 加载并展示决策列表。

第三阶段：实现“创建新决策”完整流程

开发 templates_screen.dart，提供决策模板入口。

开发 create_decision_screen.dart，用于输入决策标题和选项。

开发 select_criteria_screen.dart，让用户选择或添加评估标准。

开发 set_weights_screen.dart，使用 Slider 组件设置权重。

开发 score_options_screen.dart，完成对各选项的评分。

将整个流程中创建的 Decision 对象通过 setState 在有状态的父组件中传递，并在最后一步保存到本地。

第四阶段：报告与可视化

实现 decision_service.dart 中的核心计算逻辑：calculateScores(Decision decision)，返回每个选项的加权总分。

开发 report_screen.dart，接收一个 Decision 对象作为参数。

集成图表库（如 fl_chart），创建 radar_chart_widget.dart 并将其用于报告页，动态展示数据。

展示最终计算得分和摘要。

第五阶段：完善“洞察”与“设置”页面

在 insights_screen.dart 中，从 StorageService 加载所有决策数据，进行统计分析，并使用图表库渲染条形图和甜甜圈图。

在 settings_screen.dart 中，实现主题切换逻辑（使用 Provider 或简单的 InheritedWidget + setState 全局刷新），并实现数据导出/清除功能。

第六阶段：测试与优化

全面测试数据流，确保决策的创建、更新、删除和加载功能正常。

测试UI在不同设备上的表现。

优化性能，特别是列表滚动和图表渲染的流畅度。