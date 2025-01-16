//
//  StudentListResponseDTO.swift
//  MessageService
//
//  Created by 최지철 on 12/26/24.
//

import MessageDomain

struct StudentListResponseDTO: Decodable {
    let users: [UserDTO]
    let hasNext: Bool
    let lastCursorId: Int

    func toDomain() -> StudentListResponseEntity {
        return StudentListResponseEntity(
            users: users.map { $0.toDomain() },
            hasNext: hasNext,
            lastCursorId: lastCursorId
        )
    }
}

extension StudentListResponseDTO {
    struct UserDTO: Decodable {
        let id: Int
        let name: String
        let gender: String
        let introduction: String
        let schoolName: String
        let grade: Int
        let classNumber: Int
        let profile: UserProfileDTO

        func toDomain() -> StudentListResponseEntity.UserEntity {
            return StudentListResponseEntity.UserEntity(
                id: id,
                name: name,
                gender: gender,
                introduction: introduction,
                schoolName: schoolName,
                grade: grade,
                classNumber: classNumber,
                profile: profile.toDomain(),
                totalInfo: "\(schoolName) \(grade)학년 \(classNumber)반"
            )
        }
    }
}

extension StudentListResponseDTO.UserDTO {
    struct UserProfileDTO: Decodable {
        let backgroundColor: String
        let iconUrl: String

        func toDomain() -> StudentListResponseEntity.UserEntity.UserProfileEntity {
            return StudentListResponseEntity.UserEntity.UserProfileEntity(
                backgroundColor: backgroundColor,
                iconUrl: iconUrl
            )
        }
    }
}
