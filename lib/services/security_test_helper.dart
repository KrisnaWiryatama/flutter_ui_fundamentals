import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kos_service.dart';

Future<void> securityTest(String kosIdMilikUserA) async {
  final kos = KosService();
  
  // 1. User B mencoba mengubah data User A -> Harus ditolak (Expected: false / denied)
  final updated = await kos.update(kosIdMilikUserA, {'name': 'DIUBAH USER B'});
  debugPrint(updated
      ? '[FAIL] User B berhasil mengubah data User A'
      : '[PASS] UPDATE ditolak oleh RLS');

  // 2. User B mencoba menghapus data User A -> Harus ditolak (Expected: false / denied)
  final deleted = await kos.delete(kosIdMilikUserA);
  debugPrint(deleted
      ? '[FAIL] User B berhasil menghapus data User A'
      : '[PASS] DELETE ditolak oleh RLS');

  // 3. User B mencoba INSERT atas nama User A -> Harus memunculkan PostgrestException (Error 42501)
  try {
    await Supabase.instance.client.from('kos').insert({
      'owner_id': 'UUID_USER_A',
      'name': 'Kos Palsu',
    });
    debugPrint('[FAIL] INSERT atas nama user lain berhasil');
  } on PostgrestException catch (e) {
    debugPrint('[PASS] INSERT ditolak: ${e.code} - ${e.message}');
  }
}