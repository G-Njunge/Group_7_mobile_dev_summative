import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      appBar: AppBar(title: const Text('Pharmacy map')),
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
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
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            if (state.searchQuery.trim().isNotEmpty)
              _SearchResults(
                maxHeight: math
                    .min(176.0, constraints.maxHeight * 0.3)
                    .toDouble(),
                pharmacies: state.visiblePharmacies,
                currentLocation: state.currentLocation,
                onSelected: (pharmacy) {
                  _moveTo(pharmacy.coordinates, zoom: 15);
                  _showPharmacyDetails(context, pharmacy);
                },
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildMap(state),
                  if (state.status == PharmacyMapStatus.loading)
                    const _MapMessage(child: CircularProgressIndicator()),
                  if (state.status == PharmacyMapStatus.error)
                    _MapMessage(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ?? 'Could not load pharmacies.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => unawaited(
                              context.read<PharmacyMapCubit>().start(),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  if (state.status == PharmacyMapStatus.loaded &&
                      state.visiblePharmacies.isEmpty)
                    _MapMessage(
                      child: Text(
                        state.searchQuery.trim().isEmpty
                            ? 'No pharmacies found.'
                            : 'No pharmacies match your search.',
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 24,
                    child: FloatingActionButton(
                      tooltip: 'Locate me',
                      onPressed: state.isLocating
                          ? null
                          : () => unawaited(
                              context.read<PharmacyMapCubit>().locateMe(),
                            ),
                      child: state.isLocating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildMap(PharmacyMapState state) => FlutterMap(
    mapController: _mapController,
    options: const MapOptions(
      initialCenter: LatLng(-1.286389, 36.817223),
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
          ],
        ),
      ),
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
          return ListTile(
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
    child: ColoredBox(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      child: Center(child: child),
    ),
  );
}
