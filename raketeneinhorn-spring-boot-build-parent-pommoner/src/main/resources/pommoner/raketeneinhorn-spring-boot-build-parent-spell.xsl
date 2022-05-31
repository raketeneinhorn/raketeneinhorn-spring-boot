<xsl:stylesheet version="2.0"
                xmlns="http://maven.apache.org/POM/4.0.0"
                xmlns:pommon="https://raketeneinhorn.com/maven/pommon"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pom="http://maven.apache.org/POM/4.0.0"
                xmlns:saxon="http://saxon.sf.net/">
    <xsl:output method="xml" indent="yes"  saxon:indent-spaces="4"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="pommon.base.artifactId" required="yes" />
    <xsl:param name="pommon.target.groupId" required="yes"/>
    <xsl:param name="pommon.target.artifactId" required="yes" />

    <xsl:variable name="spring-boot.version" select="/pommon:double-headed-demon/pommon:effective/pom:project/pom:parent/pom:version"/>

    <xsl:template match="/pommon:double-headed-demon/pommon:effective/pom:project">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="copy"/>

            <xsl:apply-templates select="pom:modelVersion" mode="copy-block-with-trailing-newlines"/>

            <xsl:element name="parent">
                <xsl:element name="groupId"><xsl:value-of select="/pommon:double-headed-demon/pommon:raw/pom:project/pom:parent/pom:groupId" /></xsl:element>
                <xsl:element name="artifactId">spring-boot-dependencies</xsl:element>
                <xsl:element name="version"><xsl:value-of select="$spring-boot.version" /></xsl:element>
                <xsl:element name="relativePath"/>
            </xsl:element>
            <xsl:text>&#10;&#10;</xsl:text>

            <xsl:element name="groupId"><xsl:value-of select="$pommon.target.groupId"/></xsl:element>
            <xsl:element name="artifactId"><xsl:value-of select="$pommon.target.artifactId"/></xsl:element>
            <xsl:element name="version"><xsl:value-of select="pom:version"/></xsl:element>
            <xsl:element name="packaging">pom</xsl:element>
            <xsl:text>&#10;&#10;</xsl:text>

            <xsl:element name="properties">
                <xsl:call-template name="pretty-comment">
                    <xsl:with-param name="comment" select="concat('direct properties from ', $pommon.base.artifactId)"/>
                    <xsl:with-param name="indent-count" select="8"/>
                </xsl:call-template>
                <xsl:apply-templates select="/pommon:double-headed-demon/pommon:raw/pom:project/pom:properties/node()" mode="copy"/>
                <xsl:text>&#10;</xsl:text>

                <xsl:call-template name="pretty-comment">
                    <xsl:with-param name="comment" select="concat('derived from ', pom:parent/pom:groupId, ':', pom:parent/pom:artifactId, ':', $spring-boot.version)"/>
                    <xsl:with-param name="indent-count" select="8"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="not(/pommon:double-headed-demon/pommon:raw/pom:project/pom:properties/pom:java.version)">
                        <xsl:apply-templates select="pom:properties/pom:java.version" mode="copy"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment> property java.version was set in <xsl:value-of select="$pommon.base.artifactId"/>, skipping </xsl:comment>
                        <xsl:text>&#10;        </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:apply-templates select="pom:properties/(pom:resource.delimiter|pom:maven.compiler.source|pom:maven.compiler.target|pom:project.build.sourceEncoding|pom:project.reporting.outputEncoding)" mode="copy"/>

                <xsl:text>&#10;</xsl:text>

                <xsl:call-template name="pretty-comment">
                    <xsl:with-param name="comment" select="'computed properties'"/>
                    <xsl:with-param name="indent-count" select="8"/>
                </xsl:call-template>
                <xsl:element name="dependency.spring-boot.version"><xsl:value-of select="$spring-boot.version"/></xsl:element>

            </xsl:element>
            <xsl:text>&#10;&#10;</xsl:text>

            <xsl:apply-templates select="/pommon:double-headed-demon/pommon:raw/pom:project/(pom:url|pom:dependencyManagement|pom:build|pom:reporting|pom:profiles|pom:organization|pom:developers|pom:licenses|pom:distributionManagement)" mode="copy-block-with-trailing-newlines"/>

        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pommon:double-headed-demon/pommon:raw"/>

    <xsl:template match="@xml:base" mode="copy"/>

    <xsl:template match="@*|node()" mode="copy-block-with-trailing-newlines">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()" mode="copy"/>
        </xsl:copy>
        <xsl:text>&#10;&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="@*|node()" mode="copy">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()" mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="pretty-comment">
        <xsl:param name="comment"/>
        <xsl:param name="indent-count"/>

        <xsl:variable name="base-indent" select="string-join((for $i in 1 to $indent-count return ' '),'')" />
        <xsl:variable name="full-indent" select="string-join((for $i in 1 to ($indent-count + 4) return ' '),'')" />

        <xsl:text>&#10;</xsl:text><xsl:value-of select="$base-indent"/>
        <xsl:comment>+
<xsl:value-of select="$full-indent"/>| <xsl:value-of select="$comment"/><xsl:text>&#10;</xsl:text>
<xsl:value-of select="$full-indent"/>+</xsl:comment>
        <xsl:text>&#10;</xsl:text><xsl:value-of select="$base-indent"/>
    </xsl:template>

</xsl:stylesheet>