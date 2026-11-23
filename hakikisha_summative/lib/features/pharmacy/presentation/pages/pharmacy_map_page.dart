import 'dart:async';
import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/widgets/auth_colors.dart';
import '../../../auth/presentation/widgets/neumorphic.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../domain/entities/pharmacy_coordinates.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/utils/pharmacy_search.dart';
import '../bloc/pharmacy_map_cubit.dart';
import '../bloc/pharmacy_map_state.dart';

class PharmacyMapPage extends StatelessWidget {
  const PharmacyMapPage({required this.cubit, super.key});

  final PharmacyMapCubit cubit;

  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: cubit, child: const _PharmacyMapView());
}

class _PharmacyMapView extends StatefulWidget {
  const _PharmacyMapView();

  @override
  State<_PharmacyMapView> createState() => _PharmacyMapViewState();
}

class _PharmacyMapViewState extends State<_PharmacyMapView> {
  final MapController _mapController = MapController();
  List<PharmacyEntity> _lastPharmacies = const [];
  PharmacyCoordinates? _lastCurrentLocation;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<PharmacyMapCubit>().start());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<PharmacyMapCubit, PharmacyMapState>(
    listenWhen: (previous, current) =>
        previous.pharmacies != current.pharmacies ||
        previous.currentLocation != current.currentLocation ||
        previous.locationError != current.locationError,
    listener: (context, state) {
      if (state.pharmacies.isNotEmpty && state.pharmacies != _lastPharmacies) {
        _fitPharmacies(state.pharmacies);
      }
      if (state.currentLocation != null &&
          state.currentLocation != _lastCurrentLocation) {
        _moveTo(state.currentLocation!, zoom: 15);
      }
      if (state.locationError != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.locationError!)));
        context.read<PharmacyMapCubit>().clearLocationError();
      }
      _lastPharmacies = state.pharmacies;
      _lastCurrentLocation = state.currentLocation;
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy map'),
        backgroundColor: AuthColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: const AppDrawer(),
      body: ColoredBox(
        color: AuthColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  TextField(
                    onChanged: context.read<PharmacyMapCubit>().setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search name, address, license, or phone',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () => context
                                  .read<PharmacyMapCubit>()
                                  .setSearchQuery(''),
                              icon: const Icon(Icons.clear),
                            ),
                      filled: true,
                      fillColor: AuthColors.field,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AuthColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (state.searchQuery.trim().isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: math.min(120.0, constraints.maxHeight * 0.2),
                      ),
                      child: _SearchResults(
                        maxHeight: math.min(120.0, constraints.maxHeight * 0.2),
                        pharmacies: state.visiblePharmacies,
                        currentLocation: state.currentLocation,
                        onSelected: (pharmacy) {
                          _moveTo(pharmacy.coordinates, zoom: 15);
                          _showPharmacyDetails(context, pharmacy);
                        },
                      ),
                    ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: DecoratedBox(
                            decoration: Neu.raisedBox(
                              radius: 22,
                              color: Colors.white,
                              distance: 4,
                              blur: 10,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  _buildMap(state),
                                  if (state.status == PharmacyMapStatus.loading)
                                    const _MapMessage(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text('Loading pharmacies…'),
                                        ],
                                      ),
                                    ),
                                  if (state.status == PharmacyMapStatus.error)
                                    _MapMessage(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            state.errorMessage ??
                                                'Could not load pharmacies.',
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          FilledButton(
                                            onPressed: () => unawaited(
                                              context
                                                  .read<PharmacyMapCubit>()
                                                  .start(),
                                            ),
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (state.status ==
                                          PharmacyMapStatus.loaded &&
                                      state.visiblePharmacies.isEmpty)
                                    _MapMessage(
                                      child: Text(
                                        state.searchQuery.trim().isEmpty
                                            ? 'No pharmacies found.'
                                            : 'No pharmacies match your search.',
                                      ),
                                    ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: _ZoomControls(
                                      onZoomIn: () => _changeZoom(1),
                                      onZoomOut: () => _changeZoom(-1),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    bottom: 20,
                                    child: FloatingActionButton(
                                      tooltip: 'Locate me',
                                      onPressed: state.isLocating
                                          ? null
                                          : () => unawaited(
                                              context
                                                  .read<PharmacyMapCubit>()
                                                  .locateMe(),
                                            ),
                                      child: state.isLocating
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.my_location),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.searchQuery.trim().isEmpty
                                    ? 'Nearby pharmacies'
                                    : 'Matching pharmacies',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AuthColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (state.currentLocation == null)
                              Text(
                                'Locate to see distances',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AuthColors.textMuted),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 4,
                          child: _NearbyPharmacies(
                            pharmacies: state.visiblePharmacies,
                            currentLocation: state.currentLocation,
                            onSelected: (pharmacy) {
                              _moveTo(pharmacy.coordinates, zoom: 15);
                              _showPharmacyDetails(context, pharmacy);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildMap(PharmacyMapState state) => FlutterMap(
    mapController: _mapController,
    options: const MapOptions(
      initialCenter: LatLng(-1.9441, 30.0619),
      initialZoom: 11,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.hakikisha.app',
      ),
      MarkerLayer(
        markers: [
          for (final pharmacy in state.visiblePharmacies)
            Marker(
              point: LatLng(pharmacy.latitude, pharmacy.longitude),
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: pharmacy.name,
                onPressed: () => _showPharmacyDetails(context, pharmacy),
                icon: Icon(
                  Icons.location_on,
                  size: 38,
                  color: pharmacy.verified
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          if (state.currentLocation != null)
            Marker(
              point: LatLng(
                state.currentLocation!.latitude,
                state.currentLocation!.longitude,
              ),
              width: 32,
              height: 32,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 24,
              ),
            ),
        ],
      ),
      const RichAttributionWidget(
        attributions: [TextSourceAttribution('OpenStreetMap contributors')],
      ),
    ],
  );

  void _moveTo(PharmacyCoordinates coordinates, {required double zoom}) {
    _mapController.move(
      LatLng(coordinates.latitude, coordinates.longitude),
      zoom,
    );
  }

  void _changeZoom(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta).clamp(3.0, 18.0).toDouble();
    _mapController.move(camera.center, zoom);
  }

  void _fitPharmacies(List<PharmacyEntity> pharmacies) {
    final points = pharmacies
        .map((pharmacy) => LatLng(pharmacy.latitude, pharmacy.longitude))
        .toList();
    final firstPoint = points.first;
    final allAtSamePoint = points.every(
      (point) =>
          point.latitude == firstPoint.latitude &&
          point.longitude == firstPoint.longitude,
    );
    if (allAtSamePoint) {
      _mapController.move(firstPoint, 14);
    } else {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.all(48),
        ),
      );
    }
  }

  void _showPharmacyDetails(BuildContext context, PharmacyEntity pharmacy) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pharmacy.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(pharmacy.address),
            Text('License: ${pharmacy.licenseNo}'),
            Text(pharmacy.verified ? 'Verified pharmacy' : 'Not verified'),
            if (pharmacy.phone.trim().isNotEmpty)
              Text('Phone: ${pharmacy.phone}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => unawaited(
                    _launchExternalUrl(
                      context,
                      Uri.https('www.google.com', '/maps/dir/', {
                        'api': '1',
                        'destination':
                            '${pharmacy.latitude},${pharmacy.longitude}',
                      }),
                      'Could not open directions.',
                    ),
                  ),
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
                if (pharmacy.phone.trim().isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => unawaited(
                      _launchExternalUrl(
                        context,
                        Uri(scheme: 'tel', path: pharmacy.phone.trim()),
                        'Could not open the phone app.',
                      ),
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: Neu.raisedBox(radius: 16, distance: 3, blur: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom in',
          onPressed: onZoomIn,
          icon: const Icon(Icons.add),
        ),
        const SizedBox(
          width: 32,
          child: Divider(height: 1, color: AuthColors.shadowDark),
        ),
        IconButton(
          tooltip: 'Zoom out',
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
        ),
      ],
    ),
  );
}

class _NearbyPharmacies extends StatelessWidget {
  const _NearbyPharmacies({
    required this.pharmacies,
    required this.currentLocation,
    required this.onSelected,
  });

  final List<PharmacyEntity> pharmacies;
  final PharmacyCoordinates? currentLocation;
  final ValueChanged<PharmacyEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    if (pharmacies.isEmpty) {
      return Center(
        child: Text(
          currentLocation == null
              ? 'No pharmacies found.'
              : 'No nearby pharmacies found.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AuthColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
      itemCount: pharmacies.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        final distance = currentLocation == null
            ? null
            : PharmacySearch.distanceKm(currentLocation!, pharmacy.coordinates);
        return DecoratedBox(
          decoration: Neu.raisedBox(radius: 16, distance: 3, blur: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelected(pharmacy),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: Neu.raisedCircle(distance: 2, blur: 5),
                      child: Icon(
                        Icons.local_pharmacy_outlined,
                        color: pharmacy.verified
                            ? AuthColors.primary
                            : AuthColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pharmacy.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AuthColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            distance == null
                                ? pharmacy.address
                                : '${distance.toStringAsFixed(1)} km away · ${pharmacy.address}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AuthColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AuthColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.maxHeight,
    required this.pharmacies,
    required this.currentLocation,
    required this.onSelected,
  });

  final double maxHeight;
  final List<PharmacyEntity> pharmacies;
  final PharmacyCoordinates? currentLocation;
  final ValueChanged<PharmacyEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    if (pharmacies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('No pharmacies found.'),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = pharmacies[index];
          final distance = currentLocation == null
              ? null
              : PharmacySearch.distanceKm(
                  currentLocation!,
                  pharmacy.coordinates,
                );
          return Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              leading: Icon(
                Icons.local_pharmacy,
                color: pharmacy.verified
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text(pharmacy.name),
              subtitle: Text(
                distance == null
                    ? pharmacy.address
                    : '${pharmacy.address} · ${distance.toStringAsFixed(1)} km',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onSelected(pharmacy),
            ),
          );
        },
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          elevation: 3,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: child,
          ),
        ),
      ),
    ),
  );
}
