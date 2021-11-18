"""Plot the mokapot results"""
import mokapot
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


def read_results():
    """Read the mokapot results.

    Returns
    -------
    psms : pandas.DataFrame
    peptides : pandas.DataFrame
    proteins : pandas.DataFrame
        The mokapot results from the PSM, peptide, and protein levels.
    """
    results = {
        "psms": [],
        "peptides": [],
        "proteins": []
    }
    for res_file in snakemake.input:
        stem, _, grp, _ = res_file.split(".")
        beer = stem.split("_")[-2]
        data = pd.read_table(res_file)
        data["beer"] = beer
        results[grp].append(data)

    for key, values in results.items():
        results[key] = pd.concat(values)

    return results["psms"], results["peptides"], results["proteins"]


def create_figure(psms, peptides, proteins):
    """Create the figure.

    Parameters
    ----------
    psms : pandas.DataFrame
        The mokapot results at the PSM level.
    peptides : pandas.DataFrame
        The mokapot results at the peptide level.
    proteins : pandas.DataFrame
        The mokapot results at the protein level.
    """
    sns.set_style("ticks")
    fig, axs = plt.subplot(1, 3, figsize=(12, 4))
    levels = [psms, peptides, proteins]
    labels = ["PSMs", "Peptides", "Proteins"]
    for ax, level, label in zip(axs, levels, labels):
        ax.set_xlabel("q-value")
        ax.set_ylabel(f"Accepted {label}")
        ax.legend()
        level = level.sort_values("beer")
        for beer, data in level.groupby("beer"):
            mokapot.plot_qvalues(data["mokapot q-value"].values, label=beer)

    plt.tight_layout()
    plt.savefig(snakemake.output)


def main():
    """The main function"""
    psms, peptides, proteins = read_results()
    create_figure(psms, peptides, proteins)


if __name__ == "__main__":
    main()
