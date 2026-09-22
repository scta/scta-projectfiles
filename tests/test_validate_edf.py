import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
VALIDATOR = REPOSITORY / "scripts" / "validate_edf.py"
RNG_PI = "https://raw.githubusercontent.com/scta/edf-schema/master/src/projectfile.rng"
SCH_PI = "https://raw.githubusercontent.com/scta/edf-schema/master/src/projectfile.sch"


def edf(item_id="sample-adj001", filestem="sample-adj001", alias="cap3"):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="{RNG_PI}" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
<?xml-model href="{SCH_PI}" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
<listofFileNames>
  <header>
    <authorName>Sample Author</authorName>
    <commentaryName>Sample Work</commentaryName>
    <commentaryid>sample</commentaryid>
    <commentaryslug>sample</commentaryslug>
    <authorUri></authorUri>
    <parentWorkGroup></parentWorkGroup>
    <questionListSource></questionListSource>
    <questionListOriginalEditor></questionListOriginalEditor>
    <questionListEncoder></questionListEncoder>
    <hasWitnesses>
      <witness id="cod-q2a7yy">
        <slug>cod-q2a7yy</slug>
        <title></title>
        <initial>q2a7yy</initial>
      </witness>
    </hasWitnesses>
  </header>
  <div id="body">
    <item id="{item_id}" alias="{alias}">
      <fileName filestem="{filestem}"/>
      <title>Quaestio 1 &amp; 2</title>
      <questionTitle>Utrum α sit unum?</questionTitle>
    </item>
  </div>
</listofFileNames>
"""


class ValidateEdfTests(unittest.TestCase):
    def run_validator(self, contents, strict=False):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.xml"
            path.write_text(contents, encoding="utf-8")
            command = [sys.executable, str(VALIDATOR), "--skip-relaxng"]
            if strict:
                command.append("--require-scta-identifiers")
            command.append(str(path))
            return subprocess.run(
                command,
                capture_output=True,
                text=True,
                check=False,
            )

    def test_accepts_well_formed_edf_with_unicode_and_escaped_text(self):
        result = self.run_validator(edf(), strict=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_duplicate_ids(self):
        contents = edf().replace(
            "</div>",
            """    <item id="sample-adj001">
      <fileName filestem="sample-q2"/>
      <title>Quaestio 2</title>
    </item>
  </div>""",
        )
        result = self.run_validator(contents)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("duplicate id", result.stderr)

    def test_rejects_missing_schema_processing_instruction(self):
        result = self.run_validator(edf().replace(SCH_PI, "https://example.invalid/schema.sch"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required XML model", result.stderr)

    def test_rejects_nonstandard_item_id_in_strict_mode(self):
        result = self.run_validator(edf(item_id="sample-cap3"), strict=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("item IDs must be", result.stderr)

    def test_rejects_nonstandard_witness_id_in_strict_mode(self):
        result = self.run_validator(edf().replace("cod-q2a7yy", "P245"), strict=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("witness IDs must be", result.stderr)
