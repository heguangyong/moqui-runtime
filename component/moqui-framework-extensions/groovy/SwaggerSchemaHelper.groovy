/**
 * Swagger/OpenAPI 架构生成辅助类
 */

def generateStandardSchemas(includeExamples) {
    Map schemas = [:]

    // 标准成功响应模式
    schemas.ApiSuccessResponse = [
        type: "object",
        required: ["success", "code", "message", "meta"],
        properties: [
            success: [
                type: "boolean",
                description: "操作是否成功",
                example: true
            ],
            code: [
                type: "integer",
                format: "int32",
                description: "HTTP状态码",
                example: 200
            ],
            message: [
                type: "string",
                description: "操作结果消息",
                example: "操作成功"
            ],
            data: [
                type: "object",
                description: "业务数据",
                additionalProperties: true,
                nullable: true
            ],
            meta: [
                '$ref': "#/components/schemas/ApiMetadata"
            ]
        ]
    ]

    // 标准错误响应模式
    schemas.ApiErrorResponse = [
        type: "object",
        required: ["success", "code", "message", "errors", "meta"],
        properties: [
            success: [
                type: "boolean",
                description: "操作是否成功",
                example: false
            ],
            code: [
                type: "integer",
                format: "int32",
                description: "HTTP错误状态码",
                example: 400
            ],
            message: [
                type: "string",
                description: "错误消息",
                example: "请求参数错误"
            ],
            errors: [
                type: "array",
                description: "详细错误信息列表",
                items: [type: "string"],
                example: ["用户名不能为空", "密码长度不能少于6位"]
            ],
            data: [
                type: "object",
                description: "错误相关的额外数据",
                properties: [
                    validation: [
                        type: "object",
                        description: "字段验证错误",
                        additionalProperties: [type: "string"]
                    ],
                    errorType: [
                        type: "string",
                        description: "错误类型",
                        enum: ["client_error", "server_error", "validation_error", "not_found", "unauthorized", "forbidden"]
                    ]
                ],
                nullable: true
            ],
            meta: [
                '$ref': "#/components/schemas/ApiMetadata"
            ]
        ]
    ]

    // 列表响应模式
    schemas.ApiListResponse = [
        type: "object",
        required: ["success", "code", "message", "data", "meta"],
        properties: [
            success: [
                type: "boolean",
                description: "操作是否成功",
                example: true
            ],
            code: [
                type: "integer",
                format: "int32",
                description: "HTTP状态码",
                example: 200
            ],
            message: [
                type: "string",
                description: "操作结果消息",
                example: "查询成功"
            ],
            data: [
                type: "object",
                properties: [
                    items: [
                        type: "array",
                        description: "数据项列表",
                        items: [
                            type: "object",
                            additionalProperties: true
                        ]
                    ],
                    count: [
                        type: "integer",
                        description: "当前页数据条数",
                        example: 20
                    ]
                ]
            ],
            meta: [
                allOf: [
                    ['$ref': "#/components/schemas/ApiMetadata"],
                    [
                        type: "object",
                        properties: [
                            pagination: [
                                '$ref': "#/components/schemas/PaginationInfo"
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]

    // API 元数据模式
    schemas.ApiMetadata = [
        type: "object",
        required: ["timestamp", "requestId", "version", "component", "server"],
        properties: [
            timestamp: [
                type: "integer",
                format: "int64",
                description: "响应时间戳（毫秒）",
                example: 1699541234567
            ],
            requestId: [
                type: "string",
                description: "请求唯一标识",
                pattern: "^req_[a-zA-Z0-9]{8,12}$",
                example: "req_a1b2c3d4e5f6"
            ],
            traceId: [
                type: "string",
                description: "分布式追踪ID",
                pattern: "^trace_[a-fA-F0-9\\-]{36}$",
                example: "trace_550e8400-e29b-41d4-a716-446655440000"
            ],
            version: [
                type: "string",
                description: "API版本",
                pattern: "^\\d+\\.\\d+$",
                example: "2.0"
            ],
            component: [
                type: "string",
                description: "组件名称",
                example: "Marketplace"
            ],
            server: [
                type: "string",
                description: "服务器标识",
                example: "Moqui-localhost"
            ],
            environment: [
                type: "string",
                description: "运行环境",
                enum: ["development", "testing", "staging", "production"],
                example: "development"
            ]
        ]
    ]

    // 分页信息模式
    schemas.PaginationInfo = [
        type: "object",
        required: ["total", "page", "limit", "pageCount"],
        properties: [
            total: [
                type: "integer",
                format: "int64",
                description: "总记录数",
                minimum: 0,
                example: 1500
            ],
            page: [
                type: "integer",
                format: "int32",
                description: "当前页码（从1开始）",
                minimum: 1,
                example: 1
            ],
            limit: [
                type: "integer",
                format: "int32",
                description: "每页记录数",
                minimum: 1,
                maximum: 1000,
                example: 20
            ],
            pageCount: [
                type: "integer",
                format: "int32",
                description: "总页数",
                minimum: 0,
                example: 75
            ],
            hasNext: [
                type: "boolean",
                description: "是否有下一页",
                example: true
            ],
            hasPrevious: [
                type: "boolean",
                description: "是否有上一页",
                example: false
            ],
            firstItemIndex: [
                type: "integer",
                format: "int32",
                description: "当前页第一条记录索引",
                minimum: 1,
                example: 1
            ],
            lastItemIndex: [
                type: "integer",
                format: "int32",
                description: "当前页最后一条记录索引",
                example: 20
            ]
        ]
    ]

    if (includeExamples) {
        addResponseExamples(schemas)
    }

    return schemas
}

def generateApiPaths(componentName, includeExamples) {
    Map paths = [:]

    // 实体 API 路径
    paths["/e1/{entityName}"] = generateEntityPaths()

    // 服务 API 路径
    paths["/s1/{servicePath+}"] = generateServicePaths()

    // 特定组件路径
    if (!componentName || componentName == "marketplace") {
        paths["/s1/marketplace/construction/stats-v2"] = generateMarketplacePaths()
    }

    if (!componentName || componentName == "mcp") {
        paths["/s1/mcp/v2/chat"] = generateMcpPaths()
    }

    if (!componentName || componentName == "minio") {
        paths["/s1/minio/v2/buckets"] = generateMinioPaths()
    }

    // 认证路径
    paths["/login"] = generateAuthPaths()

    return paths
}

def generateEntityPaths() {
    return [
        get: [
            tags: ["Entity API"],
            summary: "查询实体记录",
            description: "根据实体名称查询记录，支持分页和条件查询",
            parameters: [
                [
                    name: "entityName",
                    in: "path",
                    required: true,
                    description: "实体名称",
                    schema: [type: "string"],
                    example: "examples"
                ],
                [
                    name: "pageIndex",
                    in: "query",
                    required: false,
                    description: "页码（从0开始）",
                    schema: [type: "integer", minimum: 0],
                    example: 0
                ],
                [
                    name: "pageSize",
                    in: "query",
                    required: false,
                    description: "每页大小",
                    schema: [type: "integer", minimum: 1, maximum: 1000],
                    example: 20
                ]
            ],
            responses: [
                "200": [
                    description: "查询成功",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiListResponse"]
                        ]
                    ]
                ],
                "400": [
                    description: "请求参数错误",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiErrorResponse"]
                        ]
                    ]
                ],
                "401": [
                    description: "未授权",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiErrorResponse"]
                        ]
                    ]
                ]
            ]
        ],
        post: [
            tags: ["Entity API"],
            summary: "创建实体记录",
            description: "创建新的实体记录",
            parameters: [
                [
                    name: "entityName",
                    in: "path",
                    required: true,
                    description: "实体名称",
                    schema: [type: "string"],
                    example: "examples"
                ]
            ],
            requestBody: [
                required: true,
                content: [
                    "application/json": [
                        schema: [
                            type: "object",
                            additionalProperties: true,
                            description: "实体数据"
                        ]
                    ]
                ]
            ],
            responses: [
                "201": [
                    description: "创建成功",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiSuccessResponse"]
                        ]
                    ]
                ],
                "400": [
                    description: "请求参数错误",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiErrorResponse"]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def generateServicePaths() {
    return [
        post: [
            tags: ["Service API"],
            summary: "调用服务",
            description: "调用指定的服务接口",
            parameters: [
                [
                    name: "servicePath",
                    in: "path",
                    required: true,
                    description: "服务路径",
                    schema: [type: "string"],
                    example: "marketplace/process/AllMatching"
                ]
            ],
            requestBody: [
                required: false,
                content: [
                    "application/json": [
                        schema: [
                            type: "object",
                            additionalProperties: true,
                            description: "服务参数"
                        ]
                    ]
                ]
            ],
            responses: [
                "200": [
                    description: "服务调用成功",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiSuccessResponse"]
                        ]
                    ]
                ],
                "400": [
                    description: "服务调用失败",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiErrorResponse"]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def generateMarketplacePaths() {
    return [
        get: [
            tags: ["Marketplace"],
            summary: "获取建筑工程统计信息",
            description: "获取建筑工程领域的供需统计数据（标准化响应格式 v2.0）",
            responses: [
                "200": [
                    description: "统计信息获取成功",
                    content: [
                        "application/json": [
                            schema: [
                                allOf: [
                                    ['$ref': "#/components/schemas/ApiSuccessResponse"],
                                    [
                                        type: "object",
                                        properties: [
                                            data: [
                                                type: "object",
                                                properties: [
                                                    overview: [
                                                        type: "object",
                                                        properties: [
                                                            totalDemands: [type: "integer", description: "总需求数", example: 12],
                                                            totalSupplies: [type: "integer", description: "总供给数", example: 15],
                                                            totalMatches: [type: "integer", description: "总匹配数", example: 60],
                                                            averageMatchScore: [type: "number", format: "float", description: "平均匹配分数", example: 0.57]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def generateMcpPaths() {
    return [
        post: [
            tags: ["MCP AI"],
            summary: "AI 聊天接口",
            description: "与多模态 AI 助手进行对话交互",
            requestBody: [
                required: true,
                content: [
                    "application/json": [
                        schema: [
                            type: "object",
                            required: ["message"],
                            properties: [
                                message: [type: "string", description: "用户消息", example: "你好，我需要帮助"],
                                sessionId: [type: "string", description: "会话ID", example: "session_123"],
                                aiProvider: [type: "string", description: "AI提供商", example: "zhipu", enum: ["zhipu", "openai", "claude"]]
                            ]
                        ]
                    ]
                ]
            ],
            responses: [
                "200": [
                    description: "AI 响应成功",
                    content: [
                        "application/json": [
                            schema: [
                                allOf: [
                                    ['$ref': "#/components/schemas/ApiSuccessResponse"],
                                    [
                                        type: "object",
                                        properties: [
                                            data: [
                                                type: "object",
                                                properties: [
                                                    response: [type: "string", description: "AI回复内容"],
                                                    sessionId: [type: "string", description: "会话ID"],
                                                    messageId: [type: "string", description: "消息ID"]
                                                ]
                                            ],
                                            meta: [
                                                type: "object",
                                                properties: [
                                                    sessionId: [type: "string", description: "会话ID"],
                                                    aiProvider: [type: "string", description: "AI提供商"],
                                                    tokensUsed: [type: "integer", description: "使用的token数量"],
                                                    responseType: [type: "string", description: "响应类型", example: "chat"]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def generateMinioPaths() {
    return [
        get: [
            tags: ["MinIO"],
            summary: "获取存储桶列表",
            description: "获取 MinIO 对象存储中的所有存储桶",
            responses: [
                "200": [
                    description: "桶列表获取成功",
                    content: [
                        "application/json": [
                            schema: ['$ref': "#/components/schemas/ApiListResponse"]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def generateAuthPaths() {
    return [
        post: [
            tags: ["Authentication"],
            summary: "用户登录",
            description: "用户身份认证，支持用户名密码和多因子认证",
            requestBody: [
                required: true,
                content: [
                    "application/json": [
                        schema: [
                            type: "object",
                            required: ["username", "password"],
                            properties: [
                                username: [type: "string", description: "用户名", example: "john.doe"],
                                password: [type: "string", description: "密码", example: "moqui"],
                                code: [type: "string", description: "多因子认证码（可选）", example: "123456"]
                            ]
                        ]
                    ]
                ]
            ],
            responses: [
                "200": [
                    description: "登录成功",
                    content: [
                        "application/json": [
                            schema: [
                                allOf: [
                                    ['$ref': "#/components/schemas/ApiSuccessResponse"],
                                    [
                                        type: "object",
                                        properties: [
                                            data: [
                                                type: "object",
                                                properties: [
                                                    accessToken: [type: "string", description: "JWT访问令牌"],
                                                    refreshToken: [type: "string", description: "刷新令牌"],
                                                    expiresIn: [type: "integer", description: "令牌有效期（秒）", example: 7200],
                                                    user: [
                                                        type: "object",
                                                        properties: [
                                                            userId: [type: "string", description: "用户ID"],
                                                            username: [type: "string", description: "用户名"]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
}

def addResponseExamples(schemas) {
    // 为各个模式添加完整的示例
    schemas.ApiSuccessResponse.example = [
        success: true,
        code: 200,
        message: "操作成功",
        data: [
            id: "123456",
            name: "示例数据",
            createdAt: "2023-11-09T10:30:00Z"
        ],
        meta: [
            timestamp: 1699541234567,
            requestId: "req_a1b2c3d4e5f6",
            traceId: "trace_550e8400-e29b-41d4-a716-446655440000",
            version: "2.0",
            component: "Marketplace",
            server: "Moqui-localhost",
            environment: "development"
        ]
    ]

    schemas.ApiErrorResponse.example = [
        success: false,
        code: 400,
        message: "请求参数错误",
        errors: ["用户名不能为空", "密码长度不能少于6位"],
        data: [
            validation: [
                username: "用户名不能为空",
                password: "密码长度不能少于6位"
            ],
            errorType: "validation_error"
        ],
        meta: [
            timestamp: 1699541234567,
            requestId: "req_a1b2c3d4e5f6",
            traceId: "trace_550e8400-e29b-41d4-a716-446655440000",
            version: "2.0",
            component: "Authentication",
            server: "Moqui-localhost",
            environment: "development"
        ]
    ]
}