import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/rwttambah_controller.dart';

class RwttambahView extends GetView<RwttambahController> {
  const RwttambahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    const Expanded(
                      child: Text(
                        "Tambah Riwayat Servis",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Jenis",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 10),

                Obx(
                  () => Row(
                    children: [
                      _jenisButton(
                        title: 'Servis Rutin',
                        selected:
                            controller.selectedJenis.value == 'Servis Rutin',
                        onTap: () => controller.changeJenis('Servis Rutin'),
                      ),
                      const SizedBox(width: 10),
                      _jenisButton(
                        title: 'Perbaikan',
                        selected: controller.selectedJenis.value == 'Perbaikan',
                        onTap: () => controller.changeJenis('Perbaikan'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _inputLabel("Detail"),
                const SizedBox(height: 8),
                _textField(
                  controller: controller.detailController,
                  hint: 'Contoh : Ganti Oli Gardan',
                ),

                const SizedBox(height: 20),

                _inputLabel("Tanggal"),
                const SizedBox(height: 8),

                TextField(
                  controller: controller.tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                    suffixIcon: IconButton(
                      onPressed: controller.pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _inputLabel("Odometer (km)"),
                const SizedBox(height: 8),

                TextField(
                  controller: controller.odometerController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'km',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _inputLabel("Nama Bengkel"),
                const SizedBox(height: 8),

                _textField(controller: controller.bengkelController),

                const SizedBox(height: 20),

                _inputLabel("Total Biaya"),
                const SizedBox(height: 8),

                TextField(
                  controller: controller.biayaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _inputLabel("Status"),
                const SizedBox(height: 8),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,

                    items: ['Dijadwalkan', 'Diproses', 'Selesai']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),

                    onChanged: controller.isStatusLocked.value
                        ? null
                        : (value) {
                            if (value != null) {
                              controller.changeStatus(value);
                            }
                          },
                          
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),

                  child: SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006BFF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: controller.simpanRiwayat,

                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w500));
  }

  Widget _textField({required TextEditingController controller, String? hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _jenisButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006BFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
