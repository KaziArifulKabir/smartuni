import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "University Notices",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notices")
            .orderBy(
          "date",
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading notices:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // No notices
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "No notices available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "University notices will appear here.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            physics:
            const BouncingScrollPhysics(),

            itemCount: notices.length,

            itemBuilder: (context, index) {
              final doc = notices[index];

              final Map<String, dynamic> data =
              doc.data() as Map<String, dynamic>;

              final String title =
                  data["title"]?.toString() ?? "";

              final String description =
                  data["description"]?.toString() ?? "";

              final String postedBy =
                  data["postedBy"]?.toString() ?? "";

              final String department =
                  data["department"]?.toString() ?? "";

              final String date =
              formatDate(data["date"]);

              return Container(
                margin:
                const EdgeInsets.only(bottom: 15),

                padding:
                const EdgeInsets.all(17),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),
                      blurRadius: 10,
                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // =========================================
                    // TITLE
                    // =========================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Container(
                          width: 45,
                          height: 45,

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xffE3F2FD,
                            ),

                            borderRadius:
                            BorderRadius
                                .circular(14),
                          ),

                          child: const Icon(
                            Icons.campaign_rounded,
                            color:
                            Color(0xff1565C0),
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            title,

                            style:
                            const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              Color(0xff1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =========================================
                    // DATE
                    // =========================================

                    Row(
                      children: [
                        Icon(
                          Icons
                              .calendar_today_rounded,
                          size: 14,
                          color:
                          Colors.grey.shade600,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          date,

                          style: TextStyle(
                            fontSize: 13,
                            color:
                            Colors.grey.shade600,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =========================================
                    // DESCRIPTION
                    // =========================================

                    Text(
                      description,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    // =========================================
                    // DEPARTMENT
                    // =========================================

                    if (department.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 15,
                            color:
                            Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              department,

                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // =========================================
                    // POSTED BY
                    // =========================================

                    if (postedBy.isNotEmpty) ...[
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 15,
                            color:
                            Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "Posted by: $postedBy",

                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // FORMAT FIRESTORE TIMESTAMP
  // ============================================================

  String formatDate(dynamic value) {
    if (value == null) {
      return "Date not available";
    }

    if (value is Timestamp) {
      final DateTime date = value.toDate();

      return "${date.day} ${monthName(date.month)} ${date.year}";
    }

    return value.toString();
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String monthName(int month) {
    const List<String> months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return months[month];
  }
}