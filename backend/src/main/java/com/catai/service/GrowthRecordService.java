package com.catai.service;

import com.catai.dto.request.GrowthRecordRequest;
import com.catai.dto.response.GrowthRecordResponse;
import com.catai.entity.GrowthRecord;
import com.catai.entity.Pet;
import com.catai.exception.ResourceNotFoundException;
import com.catai.exception.UnauthorizedException;
import com.catai.repository.GrowthRecordRepository;
import com.catai.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GrowthRecordService {

    private final GrowthRecordRepository growthRecordRepository;
    private final PetRepository petRepository;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public List<GrowthRecordResponse> getRecords(String petId, String userId, String type) {
        verifyPetOwnership(petId, userId);

        List<GrowthRecord> records;
        if (type != null && !type.isEmpty() && !"all".equals(type)) {
            records = growthRecordRepository.findByPetIdAndTypeOrderByDateDesc(petId, type);
        } else {
            records = growthRecordRepository.findByPetIdOrderByDateDesc(petId);
        }
        return records.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public GrowthRecordResponse createRecord(String petId, String userId, GrowthRecordRequest req) {
        verifyPetOwnership(petId, userId);

        GrowthRecord record = GrowthRecord.builder()
                .id(UUID.randomUUID().toString())
                .petId(petId)
                .date(req.getDate() != null ? req.getDate() : LocalDate.now().format(DATE_FMT))
                .weight(req.getWeight() != null ? req.getWeight() : 0.0)
                .height(req.getHeight() != null ? req.getHeight() : 0.0)
                .photo(req.getPhoto() != null ? req.getPhoto() : "")
                .notes(req.getNotes() != null ? req.getNotes() : "")
                .type(req.getType() != null ? req.getType() : "daily")
                .createTime(LocalDate.now().format(DATE_FMT))
                .build();

        growthRecordRepository.save(record);
        return toResponse(record);
    }

    @Transactional
    public void deleteRecord(String recordId, String userId) {
        GrowthRecord record = growthRecordRepository.findById(recordId)
                .orElseThrow(() -> new ResourceNotFoundException("成长记录", recordId));
        // Verify ownership through the pet
        verifyPetOwnership(record.getPetId(), userId);
        growthRecordRepository.delete(record);
    }

    private void verifyPetOwnership(String petId, String userId) {
        Pet pet = petRepository.findById(petId)
                .orElseThrow(() -> new ResourceNotFoundException("宠物", petId));
        if (!pet.getUserId().equals(userId)) {
            throw new UnauthorizedException("无权访问此宠物");
        }
    }

    private GrowthRecordResponse toResponse(GrowthRecord record) {
        return GrowthRecordResponse.builder()
                .id(record.getId())
                .petId(record.getPetId())
                .date(record.getDate())
                .weight(record.getWeight())
                .height(record.getHeight())
                .photo(record.getPhoto())
                .notes(record.getNotes())
                .type(record.getType())
                .createTime(record.getCreateTime())
                .build();
    }
}
