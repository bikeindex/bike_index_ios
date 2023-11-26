//
//  MockData.swift
//  BikeIndexTests
//
//  Created by Jack on 11/26/23.
//

import Foundation

struct MockData {
    static let userJson =
"""
{
    "username": "d16b16aea831b",
    "name": "Test User",
    "email": "test@example.com",
    "secondary_emails": [],
    "twitter": null,
    "created_at": 1694235377,
    "image": null
}
"""

    static let authenticatedUserJson =
"""
{
    "id": "591441",
    "user": \(userJson),
    "bike_ids": [

    ],
    "memberships": [
        {
            "organization_name": "Hogwarts School of Witchcraft and Wizardry",
            "organization_slug": "hogwarts",
            "organization_id": 818,
            "organization_access_token": "bdcc3c3c85716167ce566ab1418ab13b",
            "user_is_organization_admin": true
        }
    ]
}
"""

}
