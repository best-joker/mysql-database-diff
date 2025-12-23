-- 来自 Dev 的表 `attendance_record`
CREATE TABLE `attendance_record` (
  `attendance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '考勤记录id',
  `person_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '人员姓名',
  `attendance_date` date DEFAULT NULL COMMENT '考勤日期',
  `attendance_status` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '考勤状态',
  `remark` text COLLATE utf8mb4_general_ci COMMENT '备注',
  `created_time` date DEFAULT NULL COMMENT '创建日期',
  `updated_time` date DEFAULT NULL COMMENT '更新日期',
  `department_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '部门名称',
  PRIMARY KEY (`attendance_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1619 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `bed`
CREATE TABLE `bed` (
  `id` varchar(36) NOT NULL COMMENT '床位ID(UUID)',
  `room_id` varchar(36) NOT NULL COMMENT '所属房间ID(关联room表的id)',
  `bed_code` varchar(50) NOT NULL COMMENT '床位编号(如A床、B床、C床)',
  `position` varchar(20) DEFAULT NULL COMMENT '位置(WINDOW-靠窗/DOOR-靠门/MIDDLE-中间)',
  `price_month` decimal(10,2) NOT NULL COMMENT '月价格(元/月)',
  `bed_type` varchar(20) NOT NULL COMMENT '床位类型(NURSING-护理床/ELECTRIC-电动床/STANDARD-普通床)',
  `status` varchar(20) NOT NULL DEFAULT 'IDLE' COMMENT '状态(IDLE-空闲/IN_USE-入住/DISABLED-停用)',
  `remarks` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bed_code_room` (`room_id`,`bed_code`),
  KEY `idx_bed_room_id` (`room_id`),
  KEY `idx_bed_status` (`status`),
  KEY `idx_bed_type` (`bed_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='床位表';


-- 来自 Dev 的表 `bed_equipment`
CREATE TABLE `bed_equipment` (
  `id` varchar(36) NOT NULL COMMENT '关联ID(UUID)',
  `bed_id` varchar(36) NOT NULL COMMENT '床位ID(关联bed表id)',
  `equipment_type_id` varchar(36) NOT NULL COMMENT '设备类型ID(关联equipment_type表id)',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '数量(默认1)',
  `status` varchar(20) NOT NULL DEFAULT 'NORMAL' COMMENT '设备状态(NORMAL-正常/FAULT-故障)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bed_equipment` (`bed_id`,`equipment_type_id`),
  KEY `idx_bed_equipment_bed_id` (`bed_id`),
  KEY `idx_bed_equipment_type_id` (`equipment_type_id`),
  KEY `idx_bed_equipment_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='床位设备关联表';


-- 来自 Dev 的表 `building`
CREATE TABLE `building` (
  `id` varchar(36) NOT NULL COMMENT '楼栋ID(UUID)',
  `building_code` varchar(50) NOT NULL COMMENT '楼栋编号(如A栋、1号楼)',
  `name` varchar(50) NOT NULL COMMENT '楼栋名称',
  `person_id` varchar(36) DEFAULT NULL COMMENT '负责人ID(关联person表的person_id)',
  `status` varchar(32) NOT NULL COMMENT '状态(IDLE-空闲/IN_USE-使用中/RESERVED-预留/MAINTENANCE-维护中)',
  `remarks` varchar(200) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sort_order` int unsigned NOT NULL DEFAULT '999997' COMMENT '排序值，越小越靠前',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_building_code` (`building_code`),
  KEY `idx_building_status` (`status`),
  KEY `idx_building_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='楼栋表';


-- 来自 Dev 的表 `contract_material_item`
CREATE TABLE `contract_material_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `material_item_id` bigint NOT NULL COMMENT '材料项ID',
  `material_item_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联材料项名称',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL COMMENT '是否已删除:0-未删除,1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_contract_material` (`contract_id`,`material_item_id`) USING BTREE,
  KEY `idx_contract_id` (`contract_id`) USING BTREE,
  KEY `idx_material_id` (`material_item_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;


-- 来自 Dev 的表 `contract_warning_log`
CREATE TABLE `contract_warning_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `contract_id` bigint NOT NULL COMMENT '合同ID',
  `contract_title` varchar(200) DEFAULT NULL COMMENT '合同标题',
  `contract_number` varchar(100) DEFAULT NULL COMMENT '合同编号',
  `expiry_date` date DEFAULT NULL COMMENT '合同到期日期',
  `days_until_expiry` int DEFAULT NULL COMMENT '距离到期天数',
  `manager_id` varchar(64) DEFAULT NULL COMMENT '负责人ID（关联person表）',
  `manager_name` varchar(50) DEFAULT NULL COMMENT '负责人姓名（发送时快照）',
  `manager_phone` varchar(20) DEFAULT NULL COMMENT '负责人手机号（发送时快照）',
  `sms_content` text COMMENT '短信内容',
  `send_status` tinyint DEFAULT '0' COMMENT '发送状态：0-待发送，1-发送成功，2-发送失败',
  `send_time` datetime DEFAULT NULL COMMENT '发送时间',
  `error_message` varchar(500) DEFAULT NULL COMMENT '错误信息（发送失败时记录）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_warning_log_contract_id` (`contract_id`),
  KEY `idx_warning_log_send_time` (`send_time`),
  KEY `idx_warning_log_send_status` (`send_status`),
  KEY `idx_warning_log_manager_id` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='合同预警发送记录表';


-- 来自 Dev 的表 `equipment_type`
CREATE TABLE `equipment_type` (
  `id` varchar(36) NOT NULL COMMENT '设备类型ID(UUID)',
  `code` varchar(50) NOT NULL COMMENT '设备编码(唯一)',
  `name` varchar(100) NOT NULL COMMENT '设备名称',
  `category` varchar(50) DEFAULT NULL COMMENT '设备分类',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序号(数字越小越靠前)',
  `enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用(0-禁用，1-启用)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_equipment_code` (`code`),
  KEY `idx_equipment_enabled` (`enabled`),
  KEY `idx_equipment_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备类型表';


-- 来自 Dev 的表 `facility_status_dict`
CREATE TABLE `facility_status_dict` (
  `id` varchar(36) NOT NULL COMMENT '字典ID(UUID)',
  `facility_type` varchar(32) NOT NULL COMMENT '场地类型(BUILDING-楼栋/FLOOR-楼层/ROOM-房间)',
  `status_code` varchar(32) NOT NULL COMMENT '状态编码(IDLE-空闲/IN_USE-使用中/RESERVED-预留/MAINTENANCE-维护中)',
  `status_label` varchar(50) NOT NULL COMMENT '状态标签(空闲/使用中/预留/维护中)',
  `status_color` varchar(32) DEFAULT NULL COMMENT '状态颜色(用于前端展示，如#52c41a)',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序号(数字越小越靠前)',
  `enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用(0-禁用，1-启用)',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_code` (`facility_type`,`status_code`),
  KEY `idx_facility_type` (`facility_type`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='场地状态字典表';


-- 来自 Dev 的表 `fixed_asset_info`
CREATE TABLE `fixed_asset_info` (
  `asset_id` varchar(32) NOT NULL COMMENT '资产编号（主键）',
  `asset_name` varchar(100) NOT NULL COMMENT '资产名称',
  `asset_type` varchar(50) NOT NULL COMMENT '资产类型，如：办公设备、电子设备、家具、固定资产等',
  `spec_model` varchar(100) DEFAULT '' COMMENT '规格型号',
  `total_count` int NOT NULL COMMENT '资产数量',
  `original_value` decimal(12,2) NOT NULL COMMENT '资产原值，保留2位小数',
  `purchase_date` date NOT NULL COMMENT '购置日期',
  `storage_location` varchar(100) NOT NULL COMMENT '存放地点，如：XX办公楼3层302室',
  `use_department` varchar(50) NOT NULL COMMENT '使用部门，如：财务部、技术部',
  `responsible_person` varchar(50) NOT NULL COMMENT '责任人姓名',
  `asset_status` varchar(20) NOT NULL COMMENT '资产状态，可选值：在用、闲置、维修、报废、盘点中',
  `remarks` varchar(500) DEFAULT '' COMMENT '备注信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `deleted` tinyint DEFAULT '0' COMMENT '是否删除 0 未删除 1 已删除',
  `create_person_account` varchar(16) DEFAULT NULL COMMENT '入库人账号',
  PRIMARY KEY (`asset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='资产信息表';


-- 来自 Dev 的表 `floor`
CREATE TABLE `floor` (
  `id` varchar(36) NOT NULL COMMENT '楼层ID(UUID)',
  `building_id` varchar(36) NOT NULL COMMENT '所属楼栋ID(关联building表的id)',
  `name` varchar(50) NOT NULL COMMENT '楼层名称(如1层、2层、地下一层)',
  `person_id` varchar(36) DEFAULT NULL COMMENT '负责人ID(关联person表的person_id)',
  `status` varchar(32) NOT NULL COMMENT '状态(IDLE-空闲/IN_USE-使用中/RESERVED-预留/MAINTENANCE-维护中)',
  `remarks` varchar(200) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sort_order` int unsigned NOT NULL DEFAULT '999998' COMMENT '排序值，越小越靠前',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_floor_name` (`building_id`,`name`),
  KEY `idx_floor_building_id` (`building_id`),
  KEY `idx_floor_status` (`status`),
  KEY `idx_floor_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='楼层表';


-- 来自 Dev 的表 `flow_assets_info`
CREATE TABLE `flow_assets_info` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID（自增）',
  `asset_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品名称（如：A4打印纸、USB数据线）',
  `asset_category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类（如：低值易耗品-办公耗材、原材料-电子元件）',
  `specification` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '规格型号（如：80g/A4/500张、Type-C/1m/快充）',
  `unit` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '单位（如：包、根、个、kg、米）',
  `current_stock` bigint NOT NULL DEFAULT '0' COMMENT '当前库存',
  `min_stock` bigint NOT NULL DEFAULT '0' COMMENT '最低库存（库存预警阈值）',
  `unit_price` bigint NOT NULL DEFAULT '0' COMMENT '单价（元，精确到分）',
  `stock_value` decimal(15,2) GENERATED ALWAYS AS ((`current_stock` * `unit_price`)) STORED COMMENT '库存价值（元，自动计算：当前库存*单价，存储型计算列）',
  `storage_address` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '存放地址',
  `asset_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '资产编码（扫码输入或手动输入）',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态：1-在用/正常 2-停用 3-报废',
  `remark` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '备注（如：批次202505、采购日期2025-01-10）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_code` (`asset_code`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='流动资产表';


-- 来自 Dev 的表 `interview`
CREATE TABLE `interview` (
  `interview_id` int NOT NULL AUTO_INCREMENT COMMENT '招聘记录id',
  `candidate_name` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '候选人姓名',
  `position_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '面试职位id',
  `round` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '面试轮次',
  `interview_date` date NOT NULL COMMENT '面试日期',
  `interviewer_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '面试官id',
  `remark` text COLLATE utf8mb4_general_ci COMMENT '备注',
  `recruit_id` int DEFAULT NULL COMMENT '该面试记录关联的招聘记录',
  `interview_file_url` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '面试登记表文件路径',
  `interview_file_name` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '面试登记表文件名称',
  `interview_file_size` bigint DEFAULT NULL COMMENT '面试登记表文件大小',
  `created_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime DEFAULT NULL COMMENT '更新时间',
  `created_by` varchar(36) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人',
  `updated_by` varchar(36) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`interview_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `item`
CREATE TABLE `item` (
  `item_id` varchar(32) NOT NULL COMMENT '物品编号（主键，建议用自定义编码如：ITEM001）',
  `item_name` varchar(100) NOT NULL COMMENT '物品名称',
  `unit_price` decimal(10,2) NOT NULL COMMENT '物品单价',
  `stock_quantity` int DEFAULT '0' COMMENT '当前库存数量',
  `status` tinyint DEFAULT '1' COMMENT '状态：1-启用，0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`item_id`),
  KEY `idx_item_name` (`item_name`) COMMENT '物品名称索引，便于查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='物品表';


-- 来自 Dev 的表 `leave_record`
CREATE TABLE `leave_record` (
  `leave_id` bigint NOT NULL AUTO_INCREMENT COMMENT '请假id',
  `leave_person_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '请假人员id',
  `start_time` date NOT NULL COMMENT '开始时间',
  `end_time` date NOT NULL COMMENT '结束时间',
  `leave_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请假申请状态',
  `reason` text COLLATE utf8mb4_general_ci COMMENT '请假原因',
  `person_department` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '员工部门名称',
  `organization_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '机构id',
  `leave_person_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请假人名称',
  `leave_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请假类型',
  PRIMARY KEY (`leave_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `management_system_material_item_copy1`
CREATE TABLE `management_system_material_item_copy1` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `system_id` bigint NOT NULL COMMENT '评级点ID（management_system.system_id）',
  `material_item_id` bigint NOT NULL COMMENT '材料项ID（material_item.material_id）',
  `sort_order` int DEFAULT '999' COMMENT '排序序号，数字越小显示越靠前',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '创建人ID',
  `updated_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '是否删除，0-未删除，1-已删除（逻辑删除）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_system_material` (`system_id`,`material_item_id`) USING BTREE COMMENT '评级点和材料项唯一组合约束',
  KEY `idx_system_id` (`system_id`) USING BTREE COMMENT '评级点ID索引',
  KEY `idx_material_item_id` (`material_item_id`) USING BTREE COMMENT '材料项ID索引',
  KEY `idx_sort_order` (`sort_order`) USING BTREE COMMENT '排序索引',
  KEY `idx_is_deleted` (`is_deleted`) USING BTREE COMMENT '删除标记索引'
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='评级点材料项关联表';


-- 来自 Dev 的表 `material_material_item`
CREATE TABLE `material_material_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_id` bigint NOT NULL COMMENT '综合性材料ID',
  `material_item_id` bigint NOT NULL COMMENT '关联材料项ID',
  `material_item_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联材料项名称',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `is_deleted` tinyint NOT NULL COMMENT '是否删除:0-未删除,1-已删除',
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_material_material_item` (`material_id`,`material_item_id`) USING BTREE,
  KEY `idx_material_id` (`material_id`) USING BTREE,
  KEY `idx_material_item_id` (`material_item_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;


-- 来自 Dev 的表 `partner`
CREATE TABLE `partner` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '合作伙伴名称',
  `type` varchar(50) DEFAULT NULL COMMENT '合作伙伴类型',
  `status` tinyint DEFAULT '1' COMMENT '状态（1=启用，0=备选/禁用）',
  `contact_name` varchar(100) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(50) DEFAULT NULL COMMENT '联系电话',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `address` text COMMENT '地址',
  `social_credit_code` varchar(255) DEFAULT NULL COMMENT '信用代码',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='合作伙伴';


-- 来自 Dev 的表 `partner_type`
CREATE TABLE `partner_type` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type_name` varchar(50) NOT NULL COMMENT '伙伴类型名称',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `created_time` datetime NOT NULL COMMENT '创建时间',
  `updated_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='伙伴类型表';


-- 来自 Dev 的表 `position_change_record`
CREATE TABLE `position_change_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `biz_type` varchar(32) NOT NULL COMMENT '业务类型，如：equipment(设备)/asset(资产)/staff(人员)',
  `biz_id` varchar(64) NOT NULL COMMENT '业务对象ID，关联对应业务表主键',
  `original_position` varchar(255) NOT NULL COMMENT '原位置',
  `new_position` varchar(255) NOT NULL COMMENT '变更后位置',
  `change_reason` varchar(512) NOT NULL COMMENT '变更原因',
  `change_date` datetime NOT NULL COMMENT '变更日期',
  `operator_account` varchar(64) NOT NULL COMMENT '变更人账号',
  `remark` varchar(1024) DEFAULT '' COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_biz_type_biz_id` (`biz_type`,`biz_id`) COMMENT '业务类型+业务对象ID索引，用于快速查询单个对象的变更历史',
  KEY `idx_change_date` (`change_date`) COMMENT '变更日期索引，用于按时间范围查询'
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='位置变更记录表';


-- 来自 Dev 的表 `purchase_item`
CREATE TABLE `purchase_item` (
  `item_id` varchar(50) NOT NULL COMMENT '物品编号（主键）',
  `item_name` varchar(100) NOT NULL COMMENT '物品名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '规格',
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uk_item_name_spec` (`item_name`,`specification`) COMMENT '物品名称和规格的唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='采购物品表（存储物品基础信息）';


-- 来自 Dev 的表 `purchase_order`
CREATE TABLE `purchase_order` (
  `order_id` varchar(32) NOT NULL COMMENT '订单号（主键，如：PO20251208001）',
  `purchase_date` date NOT NULL COMMENT '采购日期',
  `type_id` int NOT NULL COMMENT '采购类型ID（关联采购类型表）',
  `supplier` varchar(100) NOT NULL COMMENT '供应商名称',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单总金额（由关联的物品明细汇总）',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_person_account` varchar(16) NOT NULL COMMENT '操作人员账号',
  `deleted` tinyint DEFAULT '0' COMMENT '是否删除 0-未删除 1-已删除',
  PRIMARY KEY (`order_id`),
  KEY `idx_purchase_date` (`purchase_date`) COMMENT '采购日期索引，便于按日期查询',
  KEY `idx_type_id` (`type_id`) COMMENT '采购类型索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='采购单表';


-- 来自 Dev 的表 `purchase_order_item`
CREATE TABLE `purchase_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` varchar(32) NOT NULL COMMENT '订单号（关联采购单表）',
  `item_id` varchar(32) NOT NULL COMMENT '物品编号（关联物品表）',
  `purchase_quantity` int NOT NULL COMMENT '采购数量',
  `item_unit_price` decimal(10,2) NOT NULL COMMENT '采购单价（下单时的单价，避免物品基础单价变动影响历史订单）',
  `item_total_amount` decimal(12,2) NOT NULL COMMENT '该物品总价（采购数量*采购单价）',
  `received` tinyint DEFAULT '0' COMMENT '是否已经入库 0 未入库 1已入库',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_item` (`order_id`,`item_id`) COMMENT '一个订单下同一物品只能出现一次',
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='采购单物品关联表';


-- 来自 Dev 的表 `purchase_type`
CREATE TABLE `purchase_type` (
  `type_id` int NOT NULL AUTO_INCREMENT COMMENT '采购类型ID（主键）',
  `type_name` varchar(50) NOT NULL COMMENT '采购类型名称',
  `status` tinyint DEFAULT '1' COMMENT '状态：1-启用，0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='采购类型表';


-- 来自 Dev 的表 `recruit`
CREATE TABLE `recruit` (
  `updated_by` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新人id',
  `recruit_id` int NOT NULL AUTO_INCREMENT COMMENT '招聘消息的主键',
  `department_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '部门的Id',
  `position_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位id',
  `recruit_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '招聘类型',
  `recruit_person_num` int DEFAULT NULL COMMENT '招聘需求人数',
  `expected_time` date DEFAULT NULL COMMENT '期望到岗日期',
  `urgency_level` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '招聘紧急程度',
  `created_time` datetime DEFAULT NULL COMMENT '创建日期',
  `handler_by` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '处理人id',
  `budget` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '预算',
  `handler_time` datetime DEFAULT NULL COMMENT '处理时间',
  `organization_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '机构id',
  `updated_time` datetime DEFAULT NULL COMMENT '更新时间',
  `recruit_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '进行状态',
  `committed_by` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '需求提交人id',
  PRIMARY KEY (`recruit_id` DESC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `resign`
CREATE TABLE `resign` (
  `resign_id` bigint NOT NULL AUTO_INCREMENT COMMENT '员工离职表的id（自增）',
  `person_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '离职员工的id',
  `real_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '离职员工的名字',
  `department_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '离职员工的所属部门id',
  `position_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '离职员工的岗位id',
  `joining_date` date NOT NULL COMMENT '员工的入职日期',
  `resign_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '员工离职类型',
  `resign_date` date DEFAULT NULL COMMENT '员工离职日期',
  `resign_reason` text COLLATE utf8mb4_general_ci COMMENT '员工离职原因',
  `length_service` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '员工工龄',
  `updated_by` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作人id',
  `updated_time` datetime DEFAULT NULL COMMENT '操作时间',
  PRIMARY KEY (`resign_id` DESC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `room`
CREATE TABLE `room` (
  `id` varchar(36) NOT NULL COMMENT '房间ID(UUID)',
  `floor_id` varchar(36) NOT NULL COMMENT '所属楼层ID(关联floor表的id)',
  `room_number` varchar(50) NOT NULL COMMENT '房间编号(如101、201A、B-302)',
  `name` varchar(50) NOT NULL COMMENT '房间名称',
  `type` varchar(20) NOT NULL COMMENT '房间类型(NORMAL-普通房间/ACTIVITY-活动室/FUNCTION-功能区)',
  `room_purpose` varchar(50) NOT NULL COMMENT '房间用途(RESIDENCE-居室/BEDROOM-卧室/ACTIVITY_ROOM-活动室/OFFICE-办公室等)',
  `status` varchar(32) NOT NULL COMMENT '状态(IDLE-空闲/IN_USE-使用中/RESERVED-预留/MAINTENANCE-维护中)',
  `area` decimal(8,2) NOT NULL DEFAULT '0.00' COMMENT '面积(平方米)',
  `orientation` varchar(20) DEFAULT NULL COMMENT '朝向(仅普通房间，EAST-东/SOUTH-南/WEST-西/NORTH-北/SOUTHEAST-东南/SOUTHWEST-西南/NORTHEAST-东北/NORTHWEST-西北)',
  `bed_capacity` int DEFAULT NULL COMMENT '床位容量(仅普通房间)',
  `has_bathroom` tinyint(1) DEFAULT NULL COMMENT '是否有独立卫生间(仅普通房间，0-无，1-有)',
  `max_capacity` int DEFAULT NULL COMMENT '最大容纳人数(仅活动室)',
  `equipment_list` varchar(500) DEFAULT NULL COMMENT '设备清单(仅活动室，逗号分隔)',
  `person_id` varchar(36) DEFAULT NULL COMMENT '负责人ID(关联person表的person_id)',
  `remarks` varchar(200) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sort_order` int unsigned NOT NULL DEFAULT '999999' COMMENT '排序值，越小越靠前',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_room_number` (`floor_id`,`room_number`),
  KEY `idx_room_floor_id` (`floor_id`),
  KEY `idx_room_type_status` (`type`,`status`),
  KEY `idx_room_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='房间表';


-- 来自 Dev 的表 `stock_in_record`
CREATE TABLE `stock_in_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `purchase_order_no` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '采购单号（关联采购单）',
  `supplier` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '供应商',
  `stock_in_time` datetime NOT NULL COMMENT '入库时间',
  `total_quantity` bigint NOT NULL DEFAULT '0' COMMENT '本次入库总数量',
  `operator_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '入库人ID（关联用户表）',
  `remark` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '入库备注（如验收情况、异常说明）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '逻辑删除标识：0-未删除 1-已删除',
  `asset_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库记录表（主表）';


-- 来自 Dev 的表 `stock_out_record`
CREATE TABLE `stock_out_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `outbound_date` date NOT NULL COMMENT '出库日期',
  `recipient_id` varchar(64) NOT NULL COMMENT '接收人ID（唯一标识）',
  `recipient_name` varchar(64) NOT NULL COMMENT '接收人姓名',
  `department` varchar(64) NOT NULL COMMENT '接收部门',
  `phone` varchar(20) NOT NULL COMMENT '接收人联系电话',
  `key` decimal(16,3) NOT NULL COMMENT '业务唯一标识（如前端生成的时间戳）',
  `asset_id` varchar(64) NOT NULL COMMENT '资产ID',
  `asset_name` varchar(128) NOT NULL COMMENT '资产名称',
  `specification` varchar(128) NOT NULL COMMENT '资产规格',
  `current_stock` int NOT NULL COMMENT '出库前当前库存',
  `unit` varchar(20) NOT NULL COMMENT '计量单位（件/台/个等）',
  `quantity` int NOT NULL COMMENT '出库数量',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  `operator_account` varchar(64) DEFAULT '' COMMENT '出库操作人账号（补充字段，便于追溯）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_key` (`key`) COMMENT '保证业务唯一标识不重复',
  KEY `idx_outbound_date` (`outbound_date`) COMMENT '按出库日期查询索引',
  KEY `idx_asset_id` (`asset_id`) COMMENT '按资产ID查询出库记录索引',
  KEY `idx_recipient_id` (`recipient_id`) COMMENT '按接收人ID查询索引'
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出库记录表';


-- 来自 Dev 的表 `training_record`
CREATE TABLE `training_record` (
  `training_record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '培训记录id',
  `training_record_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '培训记录类型',
  `training_record_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '培训记录名称',
  `start_time` datetime NOT NULL COMMENT '培训开始时间',
  `end_time` datetime NOT NULL COMMENT '培训结束时间',
  `location` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '培训地点',
  `speaker_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主讲人Id',
  `created_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime DEFAULT NULL COMMENT '更新时间',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '内容',
  `status` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '进行状态',
  `organization_id` varchar(36) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '机构id',
  `object` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '培训对象',
  `created_by` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人id',
  `updated_by` varchar(36) COLLATE utf8mb4_general_ci NOT NULL COMMENT '更新人id',
  `reason` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '培训事由',
  `rating_indicator` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '关联评级指标',
  `note` text COLLATE utf8mb4_general_ci COMMENT '备注（其他信息）',
  PRIMARY KEY (`training_record_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `training_record_file`
CREATE TABLE `training_record_file` (
  `file_id` bigint NOT NULL AUTO_INCREMENT COMMENT '文件id',
  `training_record_id` bigint DEFAULT NULL COMMENT '关联的培训记录id',
  `file_url` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '文件的url',
  `file_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '文件名称',
  `created_time` datetime NOT NULL COMMENT '上传日期',
  `file_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件类型',
  PRIMARY KEY (`file_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- 来自 Dev 的表 `training_record_type`
CREATE TABLE `training_record_type` (
  `type_id` bigint NOT NULL AUTO_INCREMENT COMMENT '培训类型id',
  `type_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '培训类型名称',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
