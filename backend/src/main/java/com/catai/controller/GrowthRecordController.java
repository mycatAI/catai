package com.catai.controller;

import com.catai.dto.request.GrowthRecordRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.GrowthRecordResponse;
import com.catai.service.GrowthRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class GrowthRecordController {

    private final GrowthRecordService growthRecordService;

    @GetMapping("/api/pets/{petId}/records")
    public ResponseEntity<ApiResponse<List<GrowthRecordResponse>>> getRecords(
            @PathVariable String petId,
            @RequestParam(required = false) String type,
            Authentication auth) {
        String userId = auth.getName();
        List<GrowthRecordResponse> records = growthRecordService.getRecords(petId, userId, type);
        return ResponseEntity.ok(ApiResponse.success(records));
    }

    @PostMapping("/api/pets/{petId}/records")
    public ResponseEntity<ApiResponse<GrowthRecordResponse>> createRecord(
            @PathVariable String petId,
            @RequestBody GrowthRecordRequest req,
            Authentication auth) {
        String userId = auth.getName();
        GrowthRecordResponse record = growthRecordService.createRecord(petId, userId, req);
        return ResponseEntity.ok(ApiResponse.success(record));
    }

    @DeleteMapping("/api/records/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRecord(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        growthRecordService.deleteRecord(id, userId);
        return ResponseEntity.ok(ApiResponse.success("删除成功", null));
    }
}
