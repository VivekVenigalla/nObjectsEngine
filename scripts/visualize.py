#!/usr/bin/env python3
import argparse
import os
import pandas as pd
import numpy as np
import plotly.graph_objects as go


def main():
    #in order to read the command line we use a argument parser
    parser = argparse.ArgumentParser(description="nObjectsEngine Interactive Plotly 3D Visualizer")
    parser.add_argument("-i", "--input", default="output/output.csv", help="Path to trajectory CSV file")
    parser.add_argument("-o", "--output", default="renders/orbit_3d.html", help="Path to save HTML interactive plot")
    parser.add_argument("--stride", type=int, default=1, help="Step stride for smooth frame rate")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found.")
        return

    #check if the file is present else create a new one
    os.makedirs(os.path.dirname(args.output), exist_ok=True)

    print(f"Loading trajectory data from {args.input}...")
    df = pd.read_csv(args.input) #read the csv file into a pandas data frame

    #find a collumn given a list of potential names
    def find_col(candidates):
        for c in candidates:
            if c in df.columns:
                return c
        raise KeyError(f"Could not find position columns from candidates {candidates}. Available: {list(df.columns)}")

    #direct the collumn name to each of their respective attributes
    x_col = find_col(["posX", "pos_x", "x", "px"])
    y_col = find_col(["posY", "pos_y", "y", "py"])
    z_col = find_col(["posZ", "pos_z", "z", "pz"])

    #get the time and body IDs
    times = np.sort(df["time"].unique())[::args.stride] #unique ensures there are no duplicates
    body_ids = np.sort(df["id"].unique())

    #determine fixed axis limits to make sure axis does not change during visualization
    max_bound = max(
        abs(df[x_col]).max(),
        abs(df[y_col]).max(),
        abs(df[z_col]).max()
    ) * 1.15

    #if the z axis has no spread then create an arbitrary axis size
    z_bound = max_bound if max(abs(df[z_col]).max(), 1.0) > 1.0 else max_bound * 0.1
    #create figure
    fig = go.Figure()

    #initial frame setup
    t0 = times[0]
    df_t0 = df[df["time"] == t0].sort_values("id")

    for b_id in body_ids:
        b_df = df_t0[df_t0["id"] == b_id]
        if not b_df.empty:
            #scale marker size proportionatly(eg sun and earth diff sizes)
            marker_size = 12 if b_id == 1 else 6
            fig.add_trace(
                go.Scatter3d(
                    x=b_df[x_col],
                    y=b_df[y_col],
                    z=b_df[z_col],
                    mode="markers",
                    marker=dict(size=marker_size),
                    name=f"Body {b_id}"
                )
            )

    #construct frame sequence
    frames = []
    for t in times:
        df_t = df[df["time"] == t].sort_values("id")
        frame_traces = []
        
        for b_id in body_ids:
            b_df = df_t[df_t["id"] == b_id]
            if not b_df.empty:
                marker_size = 12 if b_id == 1 else 6
                frame_traces.append(
                    go.Scatter3d(
                        x=b_df[x_col],
                        y=b_df[y_col],
                        z=b_df[z_col],
                        mode="markers",
                        marker=dict(size=marker_size)
                    )
                )
        
        frames.append(go.Frame(data=frame_traces, name=str(t)))

    fig.frames = frames

    #setup dark layout
    fig.update_layout(
        template="plotly_dark",
        title="nObjectsEngine - Kepler Motion Trajectory",
        scene=dict(
            xaxis=dict(range=[-max_bound, max_bound], title="X (m)"),
            yaxis=dict(range=[-max_bound, max_bound], title="Y (m)"),
            zaxis=dict(range=[-z_bound, z_bound], title="Z (m)"),
            aspectmode="cube"
        ),
        updatemenus=[{
            "type": "buttons",
            "showactive": False,
            "buttons": [
                {
                    "label": "▶ Play",
                    "method": "animate",
                    "args": [
                        None,
                        {
                            "frame": {"duration": 1, "redraw": True},
                            "fromcurrent": True,
                            "transition": {"duration": 0}
                        }
                    ]
                },
                {
                    "label": "⏸ Pause",
                    "method": "animate",
                    "args": [
                        [None],
                        {
                            "frame": {"duration": 1, "redraw": False},
                            "mode": "immediate",
                            "transition": {"duration": 0}
                        }
                    ]
                }
            ]
        }]
    )

    fig.write_html(args.output)
    print(f"Interactive 3D plot saved to {args.output}")
    print("Opening in default browser...")
    os.system(f"open {args.output}")


if __name__ == "__main__":
    main()