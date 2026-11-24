package org.example.logapi;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.text.SimpleDateFormat;
import java.util.*;

@RestController
public class LogController {

    @GetMapping("/api/logs")
    public List<Map<String, Object>> getLogs() {
        List<Map<String, Object>> list = new ArrayList<>();
        Random random = new Random();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        // 每次请求生成50条随机日志数据
        for (int i = 0; i < 50; i++) {
            Map<String, Object> map = new HashMap<>();

            // 1. 随机生成一个 15 位长度的字符串作为 log_id
            map.put("log_id", UUID.randomUUID().toString().replace("-", "").substring(0, 15));

            // 2. 模拟 user_id（1~50000），与客户表 ID 范围对齐
            map.put("user_id", random.nextInt(50000) + 1);

            // 3. 行为类型：1:浏览 2:加购 3:支付
            map.put("action_type", random.nextInt(3) + 1);

            // 4. 当前事件发生时间
            map.put("event_time", sdf.format(new Date()));

            list.add(map);
        }
        return list;
    }
}